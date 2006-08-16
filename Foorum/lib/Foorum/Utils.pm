package Foorum::Utils;

use strict;
use warnings;
use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/encodeHTML decodeHTML is_color/;

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

=item is_color

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



1;