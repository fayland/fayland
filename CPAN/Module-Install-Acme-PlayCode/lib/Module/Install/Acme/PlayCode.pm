package Module::Install::Acme::PlayCode;

use 5.004;
use strict;
use warnings;

use Carp qw/croak/;
use base 'Module::Install::Base';
use Acme::PlayCode;

our $VERSION = '0.01';

sub acme_playcode {
	my $self = shift;
	
	return unless $Module::Install::AUTHOR;

    
}

1;
__END__

=head1 NAME

Module::Install::Acme::PlayCode - Use your Makefile to run L<Acme::PlayCode>

=head1 SYNOPSIS

In MakeFile.PL:

    acme_playcode();

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
