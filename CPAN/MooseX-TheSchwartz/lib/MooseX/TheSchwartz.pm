package MooseX::TheSchwartz;

use Moose;
use Moose::Util::TypeConstraints;
use Digest::MD5 qw( md5_hex );
use List::Util qw( shuffle );
use DBI;

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
    => via { $_->isa('DBI') ? $_ :
             $_->isa('DBIx::Class::Schema') ? $_->storage->dbh :
             undef;
    };

has 'verbose' => ( is => 'rw', isa => 'Verbose', coerce => 1, default => 0 );

has 'dbh' => ( is => 'rw', isa => 'DBI', coerce => 1 );
has 'retry_seconds' => (is => 'rw', isa => 'Int', default => 30);

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
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
