#!/usr/bin/perl

use strict;
use warnings;
use t::Utils;
use TheSchwartz::Moosified;

plan tests => 8;

run_test {
    my $dbh = shift;
    my $client = TheSchwartz::Moosified->new();
    $client->databases([$dbh]);

    $client->can_do("Worker::Fail");
    $client->can_do("Worker::Complete");
    
    # insert a job which will fail, fail, then succeed.
    {
        my $handle = $client->insert("Worker::CompleteEventually");
        isa_ok $handle, 'TheSchwartz::Moosified::JobHandle', "inserted job";

        $client->can_do("Worker::CompleteEventually");
        $client->work_until_done;

        is($handle->failures, 1, "job has failed once");

        my $job = Worker::CompleteEventually->grab_job($client);
        ok(!$job, "a job isn't ready yet"); # hasn't been two seconds
        sleep 3;   # 2 seconds plus 1 buffer second

        $job = Worker::CompleteEventually->grab_job($client);
        ok($job, "got a job, since time has gone by");

        Worker::CompleteEventually->work_safely($job);
        is($handle->failures, 2, "job has failed twice");

        $job = Worker::CompleteEventually->grab_job($client);
        ok($job, "got the job back");

        Worker::CompleteEventually->work_safely($job);
        ok(! $handle->is_pending, "job has exited");
        is($handle->exit_status, 0, "job succeeded");
    }
};

############################################################################
package Worker::CompleteEventually;
use base 'TheSchwartz::Moosified::Worker';

sub work {
    my ($class, $job) = @_;
    my $failures = $job->failures;
    if ($failures < 2) {
        $job->failed;
    } else {
        $job->completed;
    }
    return;
}

sub keep_exit_status_for { 20 }  # keep exit status for 20 seconds after on_complete

sub max_retries { 2 }

sub retry_delay {
    my $class = shift;
    my $fails = shift;
    return [undef,2,0]->[$fails];  # fails 2 seconds first time, then immediately
}
