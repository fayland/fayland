package Padre::Plugin::WordStats;

use warnings;
use strict;

our $VERSION = '0.02';

use Wx ':everything';

my @menu = (
    ['Word stats', \&count_word_stats ],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub count_word_stats {
	my ( $self ) = @_;
	
	my $code;
    my $src = $self->selected_text;
    my $doc = $self->selected_document;
    if ( $src ) {
        $code = $src;
    } else {
        $code = $doc->text_get;
    }
    
    my ( $lines, $chars_with_space, $chars_without_space, $words );
	$lines++ while ( $code =~ /[\r\n]/g );
	$words++ while ( $code =~ /\b\w+\b/g );
	$chars_with_space++ while ( $code =~ /./g );
	$chars_without_space++ while ( $code =~ /\S/g );
	
	my $title = 'Stats For ';
	$title .= ( $src ) ? 'Selected' : 'Doc';
	my $message = <<MESSAGE;
Words: $words
Lines: $lines
Chars with spaces: $chars_with_space
Chars without spaces: $chars_without_space
MESSAGE
	
	Wx::MessageBox( $message, $title, Wx::wxOK | Wx::wxCENTRE, $self );
}

1;
__END__

=head1 NAME

Padre::Plugin::WordStats - Word stats for L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> WordStats -> Word stats

=head1 DESCRIPTION

Count how many lines, words, chars with space, chars without spaces within your L<Padre>

If there is any selection, just run with the text you selected.

If not, run with the selected whole document.

It's a simple version, if you need more, please bug me on irc.perl.org #padre

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
