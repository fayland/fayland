package Padre::Plugin::ViewInBrowser;

use warnings;
use strict;

our $VERSION = '0.03';

use Wx ':everything';

my @menu = (
    ['View in Browser', \&view_in_browser ],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub view_in_browser {
	my ( $self ) = @_;
	
	my $filename = $self->selected_filename;
	unless ( $filename ) {
		Wx::MessageBox( 'What to open? God KNOWS!',
		'Error', Wx::wxOK | Wx::wxCENTRE, $self );
		return;
	}
	Wx::LaunchDefaultBrowser($filename);
}

1;
__END__

=head1 NAME

Padre::Plugin::ViewInBrowser - view selected doc in browser for L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> ViewInBrowser -> View in Browser

=head1 DESCRIPTION

basically it's a shortcut for Wx::LaunchDefaultBrowser( $self->selected_filename );

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
