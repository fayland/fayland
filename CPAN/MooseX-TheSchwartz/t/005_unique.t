#!/usr/bin/perl

use strict;
use warnings;
use t::Utils;
use MooseX::TheSchwartz;

plan tests => 6;

run_test {
    my $dbh = shift;
    my $client = MooseX::TheSchwartz->new( scoreboard => 1 );
    $client->databases([$dbh]);

    my ($job, $handle);

    # insert a job with unique
    $job = MooseX::TheSchwartz::Job->new(
                                 funcname => 'feed',
                                 uniqkey   => "major",
                                 );
    ok($job, "made first feed major job");
    $handle = $client->insert($job);
    isa_ok $handle, 'MooseX::TheSchwartz::JobHandle';

    # insert again (notably to same db) and see it fails
    $job = MooseX::TheSchwartz::Job->new(
                                 funcname => 'feed',
                                 uniqkey  => "major",
                                 );
    ok($job, "made another feed major job");
    $handle = $client->insert($job);
    ok(! $handle, 'no handle');

    # insert same uniqkey, but different func
    $job = MooseX::TheSchwartz::Job->new(
                                 funcname => 'scratch',
                                 uniqkey   => "major",
                                 );
    ok($job, "made scratch major job");
    $handle = $client->insert($job);
    isa_ok $handle, 'MooseX::TheSchwartz::JobHandle';
};
