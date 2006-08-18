package Foorum::Utils;

use strict;
use warnings;
use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/encodeHTML decodeHTML is_color generate_random_word/;

use HTML::Entities ();

sub encodeHTML($) {
	local $_ = $_[0];
	if(defined $_) {
		$_ = HTML::Entities::encode($_);
		s/'/&apos;/g;
		s/([^\x20-\x7E])/sprintf "&#x%X;", ord($1)/eg;
	}
	return $_;
}

sub decodeHTML($) {
	return HTML::Entities::decode($_[0]);
}

=pod

=item is_color($color)

make sure color is ^\#[0-9a-zA-Z]{6}$

=cut

sub is_color {
	my $color = shift;
	if ($color =~ /^\#[0-9a-zA-Z]{6}$/) {
		return 1;
	} else {
		return 0;
	}
}

=pod

=item generate_random_word($len)

return a random word (length is $len), char is random ('A' .. 'Z', 'a' .. 'z', 0 .. 9)

!#@!$#$^%$ bad English

=cut

sub generate_random_word {
    my $len = shift;
    my @random_words = ('A' .. 'Z', 'a' .. 'z', 0 .. 9);
    my $random_word;
    
    $len = 10 unless ($len);
    
    foreach (1 .. $len) {
        $random_word .= $random_words[int(rand(scalar @random_words))];
    }
    
    return $random_word;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;