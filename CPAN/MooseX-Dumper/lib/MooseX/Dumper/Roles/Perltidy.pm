package MooseX::Dumper::Roles::Perltidy;

use Moose::Role;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

around 'Dumper' => sub {
    my $next = shift;
    
    my $dumper = $next->(@_);
    my $tidied;
    
    require Perl::Tidy;
    Perl::Tidy::perltidy( source => \$dumper, destination => \$tidied );

    return $tidied;
};

no Moose::Role;

1;
__END__

=head1 NAME

MooseX::Dumper::Roles::Perltidy - MooseX::Dumper with Perltidy

=head1 SYNOPSIS

    use MooseX::Dumper;
    
    my $dumper = MooseX::Dumper->new_with_traits( traits => ['Perltidy'] );
    print $dumper->Dumper(\$hash, \@array);

=head1 DESCRIPTION

The code are mostly copied from Data::Dumper::Perltidy

=head1 SEE ALSO

L<Data::Dumper::Perltidy>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.