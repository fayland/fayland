package Padre::Plugin::CPAN;

use warnings;
use strict;

our $VERSION = '0.01';

use Wx ':everything';
use Padre::Wx::History::TextDialog;

my @menu = (
    ['Edit Config',    \&edit_config],
    ['Install Module', \&install_module],
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
	
	my $dialog = Padre::Wx::History::TextDialog->new(
        $self, 'Module name(s):', 'Install Module', 'OK',
    );
    if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
        return;
    }
    my $module_name = $dialog->GetValue;
    $dialog->Destroy;
    unless ( defined $module_name ) {
        return;
    }
    
    my @modules = split(/\s+/, $module_name);
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
