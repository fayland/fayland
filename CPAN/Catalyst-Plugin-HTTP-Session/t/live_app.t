#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {
    eval 'require DBD::SQLite';
    plan skip_all => 'this test requires DBD::SQLite' if $@;
    eval 'require File::Temp';
    plan skip_all => 'this test requires File::Temp' if $@;
    eval 'require HTTP::Session::Store::DBI';
    plan skip_all => 'this test requires HTTP::Session::Store::DBI' if $@;
    eval { require Test::WWW::Mechanize::Catalyst }
      or plan skip_all =>
      "Test::WWW::Mechanize::Catalyst is required for this test";

    plan tests => 5;
}

use lib "t/lib";
use Test::WWW::Mechanize::Catalyst "SessionTestApp";

my $ua1 = Test::WWW::Mechanize::Catalyst->new;
my $ua2 = Test::WWW::Mechanize::Catalyst->new;

$ua1->get_ok( "http://localhost/counter?foo_sid=f2c001214aed8ee44496e1b742613901", "counter++" );
$ua1->get_ok( "http://localhost/counter?foo_sid=f2c001214aed8ee44496e1b742613901", "counter++" );
$ua2->get_ok( "http://localhost/counter?foo_sid=266f0f877adb171b46506cb4aeb817f7", "counter++" );

# Store::Test is not good enough
$ua1->content_contains( "2", "ua1 OK" );
$ua2->content_contains( "1", "ua2 OK" );

