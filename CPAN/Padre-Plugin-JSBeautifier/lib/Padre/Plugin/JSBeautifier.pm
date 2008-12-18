package Padre::Plugin::JSBeautifier;

use warnings;
use strict;

our $VERSION = '0.01';

use base 'Padre::Plugin';

sub padre_interfaces {
	'Padre::Plugin' => '0.18',
}

sub menu_plugins_simple {
	return ('JavaScript Beautifier' => [
		'4 Spaces', \&_4spaces,
		'1 Tab',    \&_1tab,
	]);
}

sub _4spaces { _js_beautify( 4, ' ' ) }
sub _1tab    { _js_beautify( 1, "\t" ) }

sub _js_beautify {
	my ( $indent_size, $indent_character ) = @_;
	
	my $win = Padre->ide->wx->main_window;

	require JavaScript::Beautifier;
	JavaScript::Beautifier->import('js_beautify');
	
	my $src = $win->selected_text;
	my $doc = $win->selected_document;
	my $code = $src ? $src : $doc->text_get;
	return unless ( defined $code and length($code) );
	
	my $pretty_js = js_beautify( $code, {
        indent_size => $indent_size,
        indent_character => $indent_character,
    } );
    
    if ( $src ) {
		my $editor = $win->selected_editor;
	    $editor->ReplaceSelection( $pretty_js );
	} else {
		$doc->text_set( $pretty_js );
	}
}

1;
__END__

=head1 NAME

Padre::Plugin::JSBeautifier - beautify javascript in L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> JavaScript Beautifier -> *

=head1 DESCRIPTION

The Plugin use L<JavaScript::Beautifier> to make javascript looks prettier.

If there is any selection, just run with the text you selected.

If not, run with the whole text from selected document.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
