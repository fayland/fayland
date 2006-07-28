#!/usr/bin/perl

use strict;
use CGI;

my $query = new CGI;

print $query->header;

foreach my $key (keys %ENV) {
	print "$key -> $ENV{$key} <br />";
}
