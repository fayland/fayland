package MooseX::TheSchwartz;

use Moose;
use Moose::Util::TypeConstraints;
use Carp;
use Scalar::Util qw( refaddr );
use List::Util qw( shuffle );
use File::Spec ();
use Storable ();
use MooseX::TheSchwartz::Job;
use MooseX::TheSchwartz::JobHandle;

our $VERSION = '0.01';

## Number of jobs to fetch at a time in find_job_for_workers.
our $FIND_JOB_BATCH_SIZE = 50;

# subtype-s
my $sub_verbose = sub {
    my $msg = shift;
    $msg =~ s/\s+$//;
    print STDERR "$msg\n";
};
subtype 'Verbose'
    => as 'CodeRef'
    => where { 1; };
coerce 'Verbose'
    => from 'Int'
    => via {
        if ($_) {
            return $sub_verbose;
        } else {
            return sub { 0 };
        }
    };

has 'verbose' => ( is => 'rw', isa => 'Verbose', coerce => 1, default => 0 );
has 'prioritize' => ( is => 'rw', isa => 'Bool', default => 0 );

has 'retry_seconds' => (is => 'rw', isa => 'Int', default => 30);
has 'retry_at' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

has 'databases' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);
has 'dead_dsns' => ( is => 'rw', isa => 'ArrayRef', lazy => 1, default => sub { [] } );

has 'all_abilities'     => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'current_abilities' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'current_job' => ( is => 'rw', isa => 'Object' );

has 'funcmap_cache' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

has 'scoreboard'  => (
    is => 'rw',
    isa => 'Str',
    trigger => sub {
        my ($self, $dir) = @_;
        
        return unless $dir;
        # no endless loop when it's a file
        if ($dir =~ /\/theschwartz\/scoreboard\./is) {
            # get the real dir from $dir regardless a file
            my (undef, $dir) = File::Spec->splitpath( $dir );
            unless (-e $dir) {
                mkdir($dir, 0755) or die "Can't create scoreboard directory '$dir': $!";
            }
            return;
        }

        # They want the scoreboard but don't care where it goes
        if (($dir eq '1') or ($dir eq 'on')) {
            $dir = File::Spec->tmpdir();
        }
    
        $dir .= '/theschwartz';
        unless (-e $dir) {
            mkdir($dir, 0755) or die "Can't create scoreboard directory '$dir': $!";
        }
        
        $self->{scoreboard} = $dir."/scoreboard.$$";
    }
);

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
}

sub shuffled_databases {
    my $self = shift;
    return shuffle( @{ $self->databases } );
}

sub insert {
    my $self = shift;

    my $job;
    if ( ref $_[0] eq 'MooseX::TheSchwartz::Job' ) {
        $job = $_[0];
    }
    else {
        $job = MooseX::TheSchwartz::Job->new(funcname => $_[0], arg => $_[1]);
    }
    $job->arg( Storable::nfreeze( $job->arg ) ) if ref $job->arg;

    for my $dbh ( $self->shuffled_databases ) {
        my $jobid;
        eval {
            $job->funcid( $self->funcname_to_id( $dbh, $job->funcname ) );
            $job->insert_time(time);

            my $row = $job->as_hashref;
            my @col = keys %$row;

            my $sql = sprintf 'INSERT INTO job (%s) VALUES (%s)',
                join( ", ", @col ), join( ", ", ("?") x @col );

            my $sth = $dbh->prepare_cached($sql);
            $sth->execute( @$row{@col} );

            $jobid = _insert_id( $dbh, $sth, "job", "jobid" );
        };

        return $jobid if defined $jobid;
    }

    return;
}

sub find_job_for_workers {
    my $client = shift;

    my ($worker_classes) = @_;
    $worker_classes ||= $client->{current_abilities};
    
    return unless (scalar @$worker_classes);

    my $limit    = $FIND_JOB_BATCH_SIZE;
    my $order_by = $client->prioritize ? 'ORDER BY priority DESC' : '';

    for my $dbh ( $client->shuffled_databases ) {

        my $unixtime = _sql_for_unixtime($dbh);

        my @jobs;
        eval {
            ## Search for jobs in this database where:
            ## 1. funcname is in the list of abilities this $client supports;
            ## 2. the job is scheduled to be run (run_after is in the past);
            ## 3. no one else is working on the job (grabbed_until is in
            ##    in the past).
            my @ids = map { $client->funcname_to_id( $dbh, $_ ) }
                      @$worker_classes;

            my $sql   = qq~SELECT * FROM job WHERE funcid IN (?) AND run_after <= $unixtime AND grabbed_until <= $unixtime $order_by LIMIT 0, $limit~;
            my @value = (join(',', @ids));

            my $sth = $dbh->prepare_cached($sql);
            $sth->execute(@value);
            while ( my $ref = $sth->fetchrow_hashref ) {
                my $job = MooseX::TheSchwartz::Job->new( $ref );
                push @jobs, $job;
            }
        };
        if ($@) {
#            unless (OK_ERRORS->{ $driver->last_error || 0 }) {
#                $client->mark_database_as_dead($hashdsn);
#            }
        }

        my $job = $client->_grab_a_job($dbh, @jobs);
        return $job if $job;
    }
}

sub get_server_time {
    my ( $client, $dbh ) = @_;
    my $unixtime_sql = _sql_for_unixtime($dbh);
    return $dbh->selectrow_array("SELECT $unixtime_sql");
}

sub _grab_a_job {
    my ( $client, $dbh, @jobs ) = @_;

    ## Got some jobs! Randomize them to avoid contention between workers.
    @jobs = shuffle(@jobs);

  JOB:
    while (my $job = shift @jobs) {
        ## Convert the funcid to a funcname, based on this database's map.
        $job->funcname( $client->funcid_to_name($dbh, $job->funcid) );

        ## Update the job's grabbed_until column so that
        ## no one else takes it.
        my $worker_class = $job->funcname;
        my $old_grabbed_until = $job->grabbed_until;
        
        my $server_time = $client->get_server_time($dbh)
            or die "expected a server time";
        
        my $new_grabbed_until = $server_time + ($worker_class->grab_for || 1);

        my $sql  = q~UPDATE job SET grabbed_until = ? WHERE jobid = ?~;
        my $sth  = $dbh->prepare($sql);
        $sth->execute($new_grabbed_until, $job->jobid);
        my $rows = $sth->rows;

        ## Update the job in the database, and end the transaction.
        if ($rows < 1) {
            next JOB;
        }
        
        $job->grabbed_until( $new_grabbed_until );

        ## Now prepare the job, and return it.
        my $handle = MooseX::TheSchwartz::JobHandle->new({
            dbh   => $dbh,
            jobid => $job->jobid,
        });
        $handle->client($client);
        $job->handle($handle);
        return $job;
    }

    return undef;
}

sub list_jobs {
    my ( $self, $arg ) = @_;

    die "No funcname" unless exists $arg->{funcname};

    my @options;
    push @options, {
        key   => 'run_after',
        op    => '<=',
        value => $arg->{run_after}
    } if exists $arg->{run_after};
    push @options, {
        key   => 'grabbed_until',
        op    => '<=',
        value => $arg->{grabbed_until}
    } if exists $arg->{grabbed_until};

    if ( $arg->{coalesce} ) {
        $arg->{coalesce_op} ||= '=';
        push @options, {
            key   => 'coalesce',
            op    => $arg->{coalesce_op},
            value => $arg->{coalesce}
        };
    }
    
    my $limit    = $arg->{limit} || $FIND_JOB_BATCH_SIZE;
    my $order_by = $self->prioritize ? 'ORDER BY priority DESC' : '';

    my @jobs;
    for my $dbh ( $self->shuffled_databases ) {
        eval {
            my $funcid = $self->funcname_to_id( $dbh, $arg->{funcname} );

            my $sql   = qq~SELECT * FROM job WHERE funcid = ? $order_by LIMIT 0, $limit~;
            my @value = ($funcid);
            for (@options) {
                $sql .= " AND $_->{key} $_->{op} ?";
                push @value, $_->{value};
            }

            my $sth = $dbh->prepare_cached($sql);
            $sth->execute(@value);
            while ( my $ref = $sth->fetchrow_hashref ) {
                my $job = MooseX::TheSchwartz::Job->new( $ref );
                push @jobs, $job;
            }
        };
    }

    return @jobs;
}

sub can_do {
    my $client = shift;
    my ($class) = @_;
    push @{ $client->{all_abilities} }, $class;
    push @{ $client->{current_abilities} }, $class;
}

sub reset_abilities {
    my $client = shift;
    $client->{all_abilities} = [];
    $client->{current_abilities} = [];
}

sub restore_full_abilities {
    my $client = shift;
    $client->{current_abilities} = [ @{ $client->{all_abilities} } ];
}

sub temporarily_remove_ability {
    my $client = shift;
    my ($class) = @_;
    $client->{current_abilities} = [
            grep { $_ ne $class } @{ $client->{current_abilities} }
        ];
    if (!@{ $client->{current_abilities} }) {
        $client->restore_full_abilities;
    }
}

sub work_on {
    my $client = shift;
    my $hstr = shift;  # Handle string
    my $job = $client->lookup_job($hstr) or
        return 0;
    return $client->work_once($job);
}

sub work {
    my $client = shift;
    my ($delay) = @_;
    $delay ||= 5;
    while (1) {
        sleep $delay unless $client->work_once;
    }
}

sub work_until_done {
    my $client = shift;
    while (1) {
        $client->work_once or last;
    }
}

## Returns true if it did something, false if no jobs were found
sub work_once {
    my $client = shift;
    my $job = shift;  # optional specific job to work on

    ## Look for a job with our current set of abilities. Note that the
    ## list of current abilities may not be equal to the full set of
    ## abilities, to allow for even distribution between jobs.
    $job ||= $client->find_job_for_workers;

    ## If we didn't find anything, restore our full abilities, and try
    ## again.
    if (!$job &&
        @{ $client->{current_abilities} } < @{ $client->{all_abilities} }) {
        $client->restore_full_abilities;
        $job = $client->find_job_for_workers;
    }

    my $class = $job ? $job->funcname : undef;
    if ($job) {
        my $priority = $job->priority ? ", priority " . $job->priority : "";
        $job->debug("TheSchwartz::work_once got job of class '$class'$priority");
    } else {
        $client->debug("TheSchwartz::work_once found no jobs");
    }

    ## If we still don't have anything, return.
    return unless $job;

    ## Now that we found a job for this particular funcname, remove it
    ## from our list of current abilities. So the next time we look for a
    ## we'll find a job for a different funcname. This prevents starvation of
    ## high funcid values because of the way MySQL's indexes work.
    $client->temporarily_remove_ability($class);

    $class->work_safely($job);

    ## We got a job, so return 1 so work_until_done (which calls this method)
    ## knows to keep looking for jobs.
    return 1;
}

sub funcid_to_name {
    my ( $client, $dbh, $funcid ) = @_;
    my $cache = $client->_funcmap_cache($dbh);
    return $cache->{funcid2name}{$funcid};
}

sub funcname_to_id {
    my ( $self, $dbh, $funcname ) = @_;

    my $dbid  = refaddr $dbh;
    my $cache = $self->_funcmap_cache($dbh);

    unless ( exists $cache->{funcname2id}{$funcname} ) {
        ## This might fail in a race condition since funcname is UNIQUE
        my $sth = $dbh->prepare_cached(
            'INSERT INTO funcmap (funcname) VALUES (?)');
        eval { $sth->execute($funcname) };

        my $id = _insert_id( $dbh, $sth, "funcmap", "funcid" );

        ## If we got an exception, try to load the record again
        if ($@) {
            my $sth = $dbh->prepare_cached(
                'SELECT funcid FROM funcmap WHERE funcname = ?');
            $sth->execute($funcname);
            $id = $sth->fetchrow_arrayref->[0]
                or croak "Can't find or create funcname $funcname: $@";
        }

        $cache->{funcname2id}{ $funcname } = $id;
        $cache->{funcid2name}{ $id } = $funcname;
        $self->funcmap_cache->{$dbid} = $cache;
    }

    $cache->{funcname2id}{$funcname};
}

sub _funcmap_cache {
    my ( $client, $dbh ) = @_;
    my $dbid = refaddr $dbh;
    unless ( exists $client->funcmap_cache->{$dbid} ) {
        my $cache = { funcname2id => {}, funcid2name => {} };
        my $sth = $dbh->prepare_cached('SELECT funcid, funcname FROM funcmap');
        $sth->execute;
        while ( my $row = $sth->fetchrow_arrayref ) {
            $cache->{funcname2id}{ $row->[1] } = $row->[0];
            $cache->{funcid2name}{ $row->[0] } = $row->[1];
        }
        $client->funcmap_cache->{$dbid} = $cache;
    }
    return $client->funcmap_cache->{$dbid};
}

sub start_scoreboard {
    my $client = shift;

    # Don't do anything if we're not configured to write to the scoreboard
    my $scoreboard = $client->scoreboard;
    return unless $scoreboard;

    # Don't do anything of (for some reason) we don't have a current job
    my $job = $client->current_job;
    return unless $job;

    my $class = $job->funcname;

    # XXX? TODO
    open(my $sb, '>', $scoreboard)
      or $job->debug("Could not write scoreboard '$scoreboard': $!");
    print $sb join("\n", ("pid=$$",
                         'funcname='.($class||''),
                         'started='.($job->grabbed_until-($class->grab_for||1)),
                         'arg='._serialize_args($job->arg),
                        )
                 ), "\n";
    close($sb);

    return;
}

# Quick and dirty serializer.  Don't use Data::Dumper because we don't need to
# recurse indefinitely and we want to truncate the output produced
sub _serialize_args {
    my ($args) = @_;

    if (ref $args) {
        if (ref $args eq 'HASH') {
            return join ',',
                   map { ($_||'').'='.substr($args->{$_}||'', 0, 200) }
                   keys %$args;
        } elsif (ref $args eq 'ARRAY') {
            return join ',',
                   map { substr($_||'', 0, 200) }
                   @$args;
        }
    } else {
        return $args;
    }
}

sub end_scoreboard {
    my $client = shift;

    # Don't do anything if we're not configured to write to the scoreboard
    my $scoreboard = $client->scoreboard;
    return unless $scoreboard;

    my $job = $client->current_job;

    open(my $sb, '>>', $scoreboard)
      or $client->debug("Could not append scoreboard '$scoreboard': $!");
    print $sb "done=".time."\n";
    close($sb);

    return;
}

sub clean_scoreboard {
    my $client = shift;

    # Don't do anything if we're not configured to write to the scoreboard
    my $scoreboard = $client->scoreboard;
    return unless $scoreboard;

    unlink($scoreboard);
}

sub DEMOLISH {
    foreach my $arg (@_) {
        # Call 'clean_scoreboard' on TheSchwartz objects
        if (ref($arg) and $arg->isa('MooseX::TheSchwartz')) {
            $arg->clean_scoreboard;
        }
    }
}

sub _insert_id {
    my ( $dbh, $sth, $table, $col ) = @_;

    my $driver = $dbh->{Driver}{Name};
    if ( $driver eq 'mysql' ) {
        return $dbh->{mysql_insertid};
    }
    elsif ( $driver eq 'Pg' ) {
        return $dbh->last_insert_id( undef, undef, undef, undef,
            { sequence => join( "_", $table, $col, 'seq' ) } );
    }
    elsif ( $driver eq 'SQLite' ) {
        return $dbh->func('last_insert_rowid');
    }
    else {
        croak "Don't know how to get last insert id for $driver";
    }
}

# SQL doesn't define a function to ask a machine of its time in
# unixtime form.  MySQL does
# but for sqlite and others, we assume "remote" time is same as local
# machine's time, which is especially true for sqlite.
sub _sql_for_unixtime {
    my ($dbh) = @_;
    
    my $driver = $dbh->{Driver}{Name};
    if ( $driver eq 'mysql' ) {
        return "UNIX_TIMESTAMP()";
    }
    
    return time();
}

1; # End of MooseX::TheSchwartz
__END__

=head1 NAME

MooseX::TheSchwartz - TheSchwartz based on Moose!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MooseX::TheSchwartz;

    my $foo = MooseX::TheSchwartz->new();
    ...

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
