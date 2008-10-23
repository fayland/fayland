#!/usr/bin/perl

use strict;
use warnings;
use t::Utils;
use MooseX::TheSchwartz;

plan tests => 14;

run_test {
    my $dbh = shift;
    my $client = MooseX::TheSchwartz->new();
    $client->databases([$dbh]);

    my @keys = qw(foo bar baz);
    my $n = 0;
    for (1..10) {
        my $key = $keys[$n++ % 3];
        my $job = MooseX::TheSchwartz::Job->new(
                                        funcname => 'Worker::CoalesceTest',
                                        arg      => { key => $key, num => $_ },
                                        coalesce => $key
                                        );
        my $h = $client->insert($job);
        ok($h, "inserted $h ($_ = $key)");
    }

    $client->reset_abilities;
    $client->can_do("Worker::CoalesceTest");

    Worker::CoalesceTest->set_client($client);

    for (1..3) {
        my $rv = eval { $client->work_once; };
        ok($rv, "did stuff");
    }
    my $rv = eval { $client->work_once; };
    ok(!$rv, "nothing to do now");
};

############################################################################
package Worker::CoalesceTest;
use base 'MooseX::TheSchwartz::Worker';

my $client;
sub set_client { $client = $_[1]; }

sub work {
    my ($class, $job) = @_;
    my $args = $job->arg;

    my $key = $args->{key};
    $job->completed;

    if ($key eq "foo") {
        while (my $job = $client->find_job_with_coalescing_prefix("Worker::CoalesceTest", "f")) {
            $job->completed;
        }
    } else {
        while (my $job = $client->find_job_with_coalescing_value("Worker::CoalesceTest", $key)) {
            $job->completed;
        }
    }
}

sub keep_exit_status_for { 20 }  # keep exit status for 20 seconds after on_complete

sub grab_for { 10 }

sub max_retries { 1 }

sub retry_delay { my $class = shift; my $fails = shift; return 2 ** $fails; }

