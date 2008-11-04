package Padre::Plugin::CPAN;

use warnings;
use strict;

our $VERSION = '0.01';

my @menu = (
    ['Edit Config', \&edit_config],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub edit_config {
	my ( $self ) = @_;
	
	# get the place of the CPAN::Config;
}

sub install_module {
	my ( $self ) = @_;
	
	
}

1;
__END__

=head1 NAME

Padre::Plugin::CPAN - CPAN in Padre

=head1 SYNOPSIS

	$>padre
	Plugins -> CPAN -> *

=head1 DESCRIPTION

CPAN in Padre

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
