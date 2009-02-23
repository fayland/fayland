package MooseX::Dumper;

use Moose;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

with 'MooseX::Traits';
has '+_trait_namespace' => ( default => 'MooseX::Dumper::Roles' );

has 'dumper_class' => (
    is => 'rw',
    isa => 'Str',
    default => sub { 'Data::Dumper' },
);

sub Dumper {
    my $self = shift;

    unless ( Class::MOP::is_class_loaded( $self->dumper_class ) ) {
        Class::MOP::load_class( $self->dumper_class );
    }

    # Data::Dump 'dump'
    foreach my $meth ( 'Dumper', 'dump', 'Dump' ) {
        if ( my $dump_code = $self->dumper_class->can($meth) ) {
            return $dump_code->(@_);
        }
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

MooseX::Dumper - Dumper with roles

=head1 SYNOPSIS

    use MooseX::Dumper;

    my $dumper = MooseX::Dumper->new_with_traits(
        traits => ['Perltidy', 'HTML'],
        dumper_class => 'Data::Dump',
    );
    print $dumper->Dumper(\$hash, \@array);

=head1 DESCRIPTION

=head1 METHODS

=head2 new_with_traits

=over 4

=item traits

Moose Roles, check L<MooseX::Dumper::Roles::Perltidy> and L<MooseX::Dumper::Roles::HTML>

=item dumper_class

L<Data::Dumper> by default. but you still have choice to use L<Data::Dump> or others.

    my $dumper = MooseX::Dumper->new( dumper_class => 'Data::Dump' );

=back

=head2 Dumper

    print $dumper->Dumper(\$hash, \@array);

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
