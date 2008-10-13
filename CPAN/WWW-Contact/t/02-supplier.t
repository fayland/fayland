#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Test::More tests => 8;
use WWW::Contact;

my $wc = new WWW::Contact;

my $supplier = $wc->get_supplier_by_email('fayland@gmail.com');
is($supplier, 1, '$supplier OK');
is($wc->supplier, 'Gmail', 'fayland@gmail.com OK');

$supplier = $wc->get_supplier_by_email('fayland@yahoo.com');
is($supplier, 1, '$supplier OK');
is($wc->supplier, 'Yahoo', 'fayland@yahoo.com OK');

$supplier = $wc->get_supplier_by_email('fayland@ymail.com');
is($supplier, 1, '$supplier OK');
is($wc->supplier, 'Yahoo', 'fayland@ymail.com OK');

$supplier = $wc->get_supplier_by_email('fayland@rocketmail.com');
is($supplier, 1, '$supplier OK');
is($wc->supplier, 'Yahoo', 'fayland@rocketmail.com OK');

1;