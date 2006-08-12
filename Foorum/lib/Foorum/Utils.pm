package Foorum::Utils;

use strict;
use warnings;
use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/encodeHTML decodeHTML/;

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


1;