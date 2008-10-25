#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {
    eval { require Test::WWW::Mechanize::Catalyst }
      or plan skip_all =>
      "Test::WWW::Mechanize::Catalyst is required for this test";

    plan tests => 5;
}

use lib "t/lib";
use Test::WWW::Mechanize::Catalyst "SessionTestApp";

my $ua1 = Test::WWW::Mechanize::Catalyst->new;
my $ua2 = Test::WWW::Mechanize::Catalyst->new;

$ua1->get_ok( "http://localhost/counter?foo_sid=xxxx", "counter++" );
$ua1->get_ok( "http://localhost/counter?foo_sid=xxxx", "counter++" );
$ua2->get_ok( "http://localhost/counter?foo_sid=yyyy", "counter++" );

# XXX? FIXME
# Store::Test is not good enough
$ua1->content_contains( "1", "ua1 OK" );
$ua2->content_contains( "1", "ua2 OK" );

