#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Test::More tests => 4;
use WWW::Contact;

my $wc = new WWW::Contact;
$wc->supplier('Unknown');

my @contacts = $wc->get_contacts('a@a.com', 'b');
my $errstr = $wc->errstr;
is($errstr, 'error!', 'get error with password b');
is(scalar @contacts, 0, 'empty contact list');

@contacts = $wc->get_contacts('a@a.com', 'c');
$errstr = $wc->errstr;
is($errstr, undef, 'get error with password c');
is(scalar @contacts, 2, 'get 2 contact list');

1;