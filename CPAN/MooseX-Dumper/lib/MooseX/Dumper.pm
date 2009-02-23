package MooseX::Dumper;

use Moose;

our $VERSION = '0.01';
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
        $self->dumper_class->import('Dumper');
    }

    return Dumper(@_);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

MooseX::Dumper - Dumper with roles

=head1 SYNOPSIS

    use MooseX::Dumper;

    my $dumper = MooseX::Dumper->new_with_traits( traits => ['Perltidy', 'HTML'] );
    print $dumper->Dumper(\$hash, \@array);

=head1 DESCRIPTION



=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
