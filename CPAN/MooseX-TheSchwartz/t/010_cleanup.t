#!/usr/bin/perl

use strict;
use warnings;
use t::Utils;
use MooseX::TheSchwartz;

plan tests => 3;

# for testing:
$MooseX::TheSchwartz::T_EXITSTATUS_CLEAN_THRES = 1; # delete 100% of the time, not 10% of the time
$MooseX::TheSchwartz::T_ERRORS_MAX_AGE = 2;         # keep errors for 3 seconds, not 1 week

run_test {
    my $dbh = shift;
    my $client = MooseX::TheSchwartz->new();
    $client->databases([$dbh]);

    $client->can_do("Worker::Fail");
    $client->can_do("Worker::Complete");
    
    # insert a job which will fail, then succeed.
    {
        my $handle = $client->insert("Worker::Fail");
        isa_ok $handle, 'MooseX::TheSchwartz::JobHandle', "inserted job";
        
        use Data::Dumper;
        #diag(Dumper(\$client->current_abilities));

        $client->work_until_done;
        is($handle->failures, 1, "job has failed once");
        
        my $error = $dbh->selectrow_array("SELECT COUNT(*) FROM error");
        diag("$error errors");

        my $min;
        my $rows = $dbh->selectrow_array("SELECT COUNT(*) FROM exitstatus");
        is($rows, 1, "has 1 exitstatus row");

=pod

        ok($client->insert("Worker::Complete"), "inserting to-pass job");
        $client->work_until_done;
        $rows = $dbh->selectrow_array("SELECT COUNT(*) FROM exitstatus");
        is($rows, 2, "has 2 exitstatus rows");
        ($rows, $min) = $dbh->selectrow_array("SELECT COUNT(*), MIN(jobid) FROM error");
        is($rows, 1, "has 1 error rows");
        is($min, 1, "error jobid is the old one");

        # wait for exit status to pass
        sleep 3;

        # now make another job fail to cleanup some errors
        $handle = $client->insert("Worker::Fail");
        $client->work_until_done;

        $rows = $dbh->selectrow_array("SELECT COUNT(*) FROM exitstatus");
        is($rows, 1, "1 exit status row now");

        ($rows, $min) = $dbh->selectrow_array("SELECT COUNT(*), MIN(jobid) FROM error");
        is($rows, 1, "has 1 error row still");
        is($min, 3, "error jobid is only the new one");

=cut

    }
};

############################################################################
package Worker::Fail;

use base 'TheSchwartz::Worker';

sub work {
    my ($class, $job) = @_;
    
    $class->keep_exit_status_for(1); # keep exit status for 20 seconds after on_complete
    $class->max_retries(0);
    $class->retry_delay(1);
    
    $job->failed("an error message");
    return;
}

package Worker::Complete;

use base 'TheSchwartz::Worker';

sub work {
    my ($class, $job) = @_;
    
    $class->keep_exit_status_for(1);
    
    $job->completed;
    return;
}
