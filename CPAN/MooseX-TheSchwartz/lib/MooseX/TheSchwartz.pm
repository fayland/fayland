package MooseX::TheSchwartz;

use Moose;
use Moose::Util::TypeConstraints;
use Scalar::Util qw( refaddr );
use DBI;
use Carp;
use MooseX::TheSchwartz::Job;
use Storable ();

our $VERSION = '0.01';

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

subtype 'DBI'
    => as 'Object'
    => where { 1; };
coerce 'DBI'
    => from 'ArrayRef'
    => via { DBI->connect(@$_); }
    => from 'Object'
    => via { $_->isa('DBI::db') ? $_ :
             $_->isa('DBIx::Class::Schema') ? $_->storage->dbh :
             undef;
    };

has 'verbose' => ( is => 'rw', isa => 'Verbose', coerce => 1, default => 0 );

has 'dbh' => ( is => 'rw', isa => 'DBI', coerce => 1 );
has 'retry_seconds' => (is => 'rw', isa => 'Int', default => 30);
has '_funcmap' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

has 'databases' => ( is => 'rw', isa => 'ArrayRef', lazy => 1, default => sub { return [ shift->dbh ] } );

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
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

    for my $dbh ( @{ $self->databases } ) {
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

sub funcname_to_id {
    my ( $self, $dbh, $funcname ) = @_;

    my $dbid = refaddr $dbh;
    unless ( exists $self->_funcmap->{$dbid} ) {
        my $sth
            = $dbh->prepare_cached('SELECT funcid, funcname FROM funcmap');
        $sth->execute;
        while ( my $row = $sth->fetchrow_arrayref ) {
            $self->_funcmap->{$dbid}{ $row->[1] } = $row->[0];
        }
        $sth->finish;
    }

    unless ( exists $self->_funcmap->{$dbid}{$funcname} ) {
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

        $self->_funcmap->{$dbid}{$funcname} = $id;
    }

    $self->_funcmap->{$dbid}{$funcname};
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

    my @jobs;
    for my $dbh ( @{ $self->databases } ) {
        eval {
            my $funcid = $self->funcname_to_id( $dbh, $arg->{funcname} );

            my $sql   = 'SELECT jobid, arg, funcid, priority FROM job WHERE funcid = ?';
            my @value = ($funcid);
            for (@options) {
                $sql .= " AND $_->{key} $_->{op} ?";
                push @value, $_->{value};
            }

            my $sth = $dbh->prepare_cached($sql);
            $sth->execute(@value);
            while ( my $ref = $sth->fetchrow_hashref ) {
                # XXX? FIX ME! need fix it here!!! can't add priority => $ref->{priority},
                my $job = MooseX::TheSchwartz::Job->new( {
                    jobid => $ref->{jobid},
                    arg => $ref->{arg},
                    funcid => $ref->{funcid},
                } );
                push @jobs, $job;
            }
        };
    }

    return @jobs;
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
