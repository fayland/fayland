package MooseX::TheSchwartz;

use Moose;
use Moose::Util::TypeConstraints;
use Carp;
use Scalar::Util qw( refaddr );
use List::Util qw( shuffle );
use File::Spec ();
use Storable ();
use MooseX::TheSchwartz::Job;

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
