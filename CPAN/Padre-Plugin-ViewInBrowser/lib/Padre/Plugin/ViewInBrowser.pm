package Padre::Plugin::ViewInBrowser;

use warnings;
use strict;

our $VERSION = '0.02';

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
	if ( $^O eq 'MSWin32' ) {
		unless ( $filename ) {
			Wx::MessageBox( 'What to open? God KNOWS!',
			'Error', Wx::wxOK | Wx::wxCENTRE, $self );
		}
		my $cmd = qq{rundll32 url.dll,FileProtocolHandler "$filename"};
		system($cmd);
	} else {
		my $firefox_exe = _find_firefox();
		unless ( $firefox_exe ) {
			Wx::MessageBox( 'Do not know where is the browser! hmm, send me a patch to fayland at gmail dot com',
				'Error', Wx::wxOK | Wx::wxCENTRE, $self );
			return;
		}
		my $cmd = "$firefox_exe $filename";
		system($cmd);
	}
}

sub _find_firefox {

	my $name = 'firefox';
	
	for my $prefix (qw(/usr /usr/local /opt/local /sw)) {
        for my $bindir (qw(bin sbin)) {
        	require Path::Class::File;
            my $exe = Path::Class::File->new($prefix, $bindir, $name);
            return $exe if -x $exe;
        }
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

view selected doc in browser (IE/FF) or other external script.

=head2 Win32

on Win32, we use

  rundll32 url.dll,FileProtocolHandler "$filename"

it works perfect. it will open HTML in Firefox or IE, while open .pl file with L<Padre> or UE32.

=head2 Others

on Other OSes, we try to find 'firefox' then call

  $firefox_exe $filename

I'm not sure if it works or not, it's NOT tested.

patches are welcome! :)

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
