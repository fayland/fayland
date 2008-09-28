#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Test::More tests => 2;
use WWW::Contact::Unknown;

my $wc = new WWW::Contact::Unknown;
#$wc->supplier('Unknown');

my @contacts = $wc->get_contacts('a@a.com', 'b');
my $errstr = $wc->errstr;
is($errstr, 'error!', 'get error with password b');
is(scalar @contacts, 0, 'empty contact list');

1;