package MooseX::TheSchwartz::Job;

use Moose;
use Moose::Util::TypeConstraints;
use Storable ();
use MooseX::TheSchwartz::Utils qw/sql_for_unixtime/;
use MooseX::TheSchwartz::JobHandle;

subtype 'Args'
    => as 'Any'
    => where { 1; };
coerce 'Args'
    => from 'Str'
    => via { _cond_thaw($_) }
    => from 'ScalarRef'
    => via { Storable::thaw($$_) };

has 'jobid'         => ( is => 'rw', isa => 'Int' );
has 'funcid'        => ( is => 'rw', isa => 'Int' );
has 'arg'           => ( is => 'rw', isa => 'Args' );
has 'uniqkey'       => ( is => 'rw', isa => 'Maybe[Str]' );
has 'insert_time'   => ( is => 'rw', isa => 'Maybe[Int]' );
has 'run_after'     => ( is => 'rw', isa => 'Int', default => time() );
has 'grabbed_until' => ( is => 'rw', isa => 'Int', default => 0 );
has 'priority'      => ( is => 'rw', isa => 'Maybe[Int]' );
has 'coalesce'      => ( is => 'rw', isa => 'Maybe[Str]' );

has 'funcname' => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        
        my $handle = $self->handle;
        my $client = $handle->client;
        my $dbh    = $handle->dbh;
        my $funcname = $client->funcid_to_name($dbh, $self->funcid)
            or die "Failed to lookup funcname of job $self";
        return $funcname;
    }
);
has 'handle' => ( is => 'rw', isa => 'MooseX::TheSchwartz::JobHandle' );

has 'did_something' => ( is => 'rw', isa => 'Bool', default => 0 );

sub debug {
    my ($self, $msg) = @_;
    
    $self->handle->client->debug($msg, $self);
}

sub as_hashref {
    my $self = shift;

    my %data;
    for my $col (qw( jobid funcid arg uniqkey insert_time run_after grabbed_until priority coalesce )) {
        $data{$col} = $self->$col if $self->can($col);
    }

    \%data;
}

sub add_failure {
    my $job = shift;
    my ($msg) = @_;
    
    my $sql = q~INSERT INTO error SET error_time = ?, jobid = ?, message = ?, funcid = ?~;
    my $dbh = $job->handle->dbh;
    my $sth = $dbh->prepare($sql);
    $sth->execute(time(), $job->jobid, $msg || '', $job->funcid);

    # and let's lazily clean some errors while we're here.
    my $maxage = $MooseX::TheSchwartz::T_ERRORS_MAX_AGE || (86400*7);
    my $dtime  = time() - $maxage;
    $dbh->do(qq~DELETE FROM error WHERE error_time < $dtime~);

    return 1;
}

sub completed {
    my $job = shift;
    
    $job->debug("job completed");
    if ($job->did_something) {
        $job->debug("can't call 'completed' on already finished job");
        return 0;
    }
    $job->did_something(1);
    $job->set_exit_status(0);
    $job->remove();
}

sub remove {
    my ($job) = @_;
    
    my $dbh = $job->handle->dbh;
    my $jobid = $job->jobid;
    $dbh->do(qq~DELETE FROM job WHERE jobid = $jobid~);
}

sub exit_status { shift->handle->exit_status }
sub failure_log { shift->handle->failure_log }
sub failures    { shift->handle->failures    }

sub set_exit_status {
    my $job = shift;
    my($exit) = @_;
    my $class = $job->funcname;
    my $secs = $class->keep_exit_status_for or return;
    
    my $sql = q~INSERT INTO exitstatus SET jobid=?, funcid=?, status=?, completion_time=?, delete_after=?~;
    my $dbh = $job->handle->dbh;
    my $sth = $dbh->prepare($sql);
    $sth->execute( $job->jobid, $job->funcid, $exit, time(), time() + $secs );

    # and let's lazily clean some exitstatus while we're here.  but
    # rather than doing this query all the time, we do it 1/nth of the
    # time, and deleting up to n*10 queries while we're at it.
    # default n is 10% of the time, doing 100 deletes.
    my $clean_thres = $MooseX::TheSchwartz::T_EXITSTATUS_CLEAN_THRES || 0.10;
    if (rand() < $clean_thres) {
        my $unixtime = sql_for_unixtime();
        $dbh->do(qq~DELETE FROM exitstatus WHERE delete_after < $unixtime~);
    }

    return 1;
}

sub permanent_failure {
    my ($job, $msg, $ex_status) = @_;
    if ($job->did_something) {
        $job->debug("can't call 'permanent_failure' on already finished job");
        return 0;
    }
    $job->_failed($msg, $ex_status, 0);
}

sub failed {
    my ($job, $msg, $ex_status) = @_;
    if ($job->did_something) {
        $job->debug("can't call 'failed' on already finished job");
        return 0;
    }

    ## If this job class specifies that jobs should be retried,
    ## update the run_after if necessary, but keep the job around.

    my $class       = $job->funcname;
    my $failures    = $job->failures + 1;    # include this one, since we haven't ->add_failure yet
    my $max_retries = $class->max_retries($job);

    $job->debug("job failed.  considering retry.  is max_retries of $max_retries >= failures of $failures?");
    $job->_failed($msg, $ex_status, $max_retries >= $failures, $failures);
}

sub _failed {
    my ($job, $msg, $exit_status, $_retry, $failures) = @_;
    $job->did_something(1);
    $job->debug("job failed: " . ($msg || "<no message>"));

    ## Mark the failure in the error table.
    $job->add_failure($msg);

    if ($_retry) {
        my $class = $job->funcname;
        my $sql = q~UPDATE job SET ~;
        if (my $delay = $class->retry_delay($failures)) {
            my $run_after = time() + $delay;
            $job->run_after($run_after);
            $sql .= q~run_after = $run_after, ~;
        }
        $sql .= q~grabbed_until=0~;
        $job->handle->dbh->do($sql);
    } else {
        $job->set_exit_status($exit_status || 1);
        $job->remove();
    }
}

sub replace_with {
    my $job = shift;
    my(@jobs) = @_;

    if ($job->did_something) {
        $job->debug("can't call 'replace_with' on already finished job");
        return 0;
    }
    # Note: we don't set 'did_something' here because completed does it down below.

    ## The new jobs @jobs should be inserted into the same database as $job,
    ## which they're replacing. So get a driver for the database that $job
    ## belongs to.
    my $handle = $job->handle;
    my $client = $handle->client;
    my $dbh    = $handle->dbh;

    $job->debug("replacing job with " . (scalar @jobs) . " other jobs");

    ## XXX? TODO
    ## Start a transaction.

    ## Insert the new jobs.
    for my $j (@jobs) {
        $client->insert($j);
    }

    ## Mark the original job as completed successfully.
    $job->completed;
}

sub set_as_current {
    my $job = shift;
    my $client = $job->handle->client;
    $client->set_current_job($job);
}

sub _cond_thaw {
    my $data = shift;

    my $magic = eval { Storable::read_magic($data); };
    if ($magic && $magic->{major} && $magic->{major} >= 2 && $magic->{major} <= 5) {
        my $thawed = eval { Storable::thaw($data) };
        if ($@) {
            # false alarm... looked like a Storable, but wasn't.
            return $data;
        }
        return $thawed;
    } else {
        return $data;
    }
}

1;
__END__
