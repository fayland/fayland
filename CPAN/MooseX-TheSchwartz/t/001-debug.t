#!/usr/bin/perl

use Test::More;
use MooseX::TheSchwartz;

BEGIN {

    eval "use Test::Output; 1;"
        or plan skip_all => "Test::Output is required for this test";

    plan tests => 3;
};

my $client = new MooseX::TheSchwartz;
stderr_is(sub { $client->debug('A') }, '', 'no output');
$client->verbose(1);
stderr_is(sub { $client->debug('A') }, "A\n", 'A after verbose 1');
$client->verbose( sub {
    my $msg = shift;
    print STDERR "[MSG] $msg\n";
} );
stderr_is(sub { $client->debug('A') }, "[MSG] A\n", '[MSG] A after verbose sub');
