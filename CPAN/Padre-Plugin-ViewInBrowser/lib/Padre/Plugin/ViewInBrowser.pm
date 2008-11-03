package Padre::Plugin::ViewInBrowser;

use warnings;
use strict;

our $VERSION = '0.01';

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
	
	if ( $^O eq 'MSWin32' ) {
		my $filename = $self->selected_filename;
		unless ( $filename ) {
			Wx::MessageBox( 'What to open? God KNOWS!',
			'Error', Wx::wxOK | Wx::wxCENTRE, $self );
		}
		my $cmd = qq{rundll32 url.dll,FileProtocolHandler "$filename"};
		system($cmd);
	} else {
		Wx::MessageBox( 'Only Win32 is supported for now, patches are welcome',
			'Error', Wx::wxOK | Wx::wxCENTRE, $self );
	}
}

1;
__END__

=head1 NAME

Padre::Plugin::ViewInBrowser - view selected doc in browser for L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> ViewInBrowser -> View in Browser

=head1 DESCRIPTION

view selected doc in browser (IE/FF)

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
