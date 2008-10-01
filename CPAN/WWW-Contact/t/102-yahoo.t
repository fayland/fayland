#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Test::More tests => 4;
use WWW::Contact;
use Data::Dumper;

### XXX? TODO
# test connection

my $wc = new WWW::Contact;

my @contacts = $wc->get_contacts('cpan@yahoo.com', 'pass');
my $errstr = $wc->errstr;
is($errstr, 'Wrong Password', 'get error with wrong password');
is(scalar @contacts, 0, 'empty contact list');

SKIP: {
    skip "set ENV TEST_YAHOO and TEST_YAHOO_PASS to test real", 2
        unless ( $ENV{TEST_YAHOO} and $ENV{TEST_YAHOO_PASS} );

    @contacts = $wc->get_contacts($ENV{TEST_YAHOO}, $ENV{TEST_YAHOO_PASS});
    $errstr = $wc->errstr;
    is($errstr, undef, 'no error with password c');
    cmp_ok(scalar @contacts, '>', 0, 'get contact list');
    diag(Dumper(\@contacts));
}

1;