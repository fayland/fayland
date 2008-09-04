package MooseX::TheSchwartz::Worker;

use Moose::Role;

requires 'work';

has 'keep_exit_status_for' => ( is => 'rw', isa => 'Int', default => 0 );
has 'max_retries' => ( is => 'rw', isa => 'Int', default => 0 );
has 'retry_delay' => ( is => 'rw', isa => 'Int', default => 0 );
has 'grab_for' => ( is => 'rw', isa => 'Int', default => 3600 ); # 1 hour

sub grab_job {
    my $class = shift;
    my($client) = @_;
    return $client->find_job_for_workers([ $class ]);
}

sub work_safely {
    my ($class, $job) = @_;
    my $client = $job->handle->client;
    my $res;

    $job->debug("Working on $class ...");
    $job->set_as_current;
    $client->start_scoreboard;

    eval {
        $res = $class->work($job);
    };

    my $cjob = $client->current_job;
    if ($@) {
        $job->debug("Eval failure: $@");
        $cjob->failed($@);
    }
    unless ($cjob->did_something) {
        $cjob->failed('Job did not explicitly complete, fail, or get replaced');
    }

    $client->end_scoreboard;

    # FIXME: this return value is kinda useless/undefined.  should we even return anything?  any callers? -brad
    return $res;
}

1;
__END__

=head1 NAME

TheSchwartz::Worker - superclass for defining task behavior

=head1 SYNOPSIS

    package MyWorker;
    
    use Moose;
    with 'MooseX::TheSchwartz::Worker';

    sub work {
        my $class = shift;
        my $job = shift;

        print "Workin' hard or hardly workin'? Hyuk!!\n";

        $job->completed();
    }

=head1 DESCRIPTION

