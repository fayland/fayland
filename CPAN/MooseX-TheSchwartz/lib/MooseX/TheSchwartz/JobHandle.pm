package MooseX::TheSchwartz::JobHandle;

use MooseX::TheSchwartz::Job;
use Moose;

has 'jobid'  => ( is => 'rw', isa => 'Int' );
has 'client' => ( is => 'rw', isa => 'Object' );
has 'dbh'    => ( is => 'rw', isa => 'Object' );

sub job {
    my $handle = shift;
    
    my $dbh = $handle->dbh;
    my $sql = qq~SELECT * FROM job WHERE jobid = ?~;
    my $sth = $dbh->prepare_cached($sql);
    $sth->execute($handle->jobid);
    my $row = $sth->fetchrow_hashref;
    if ($row) {
        my $job = MooseX::TheSchwartz::Job->new( $row );
        $job->handle($handle);
        return $job;
    }
}

sub is_pending {
    my $handle = shift;
    return $handle->job ? 1 : 0;
}

sub exit_status {
    my $handle = shift;
    
    my $dbh = $handle->dbh;
    my $sql = q~SELECT status FROM exitstatus WHERE jobid = ?~;
    my $sth = $dbh->prepare($sql);
    $sth->execute($handle->jobid);
    my ($status) = $sth->fetchrow_array;
    return $status;
}

sub failure_log {
    my $handle = shift;
    
    my $dbh = $handle->dbh;
    my $sql = q~SELECT message FROM error WHERE jobid = ?~;
    my $sth = $dbh->prepare($sql);
    $sth->execute($handle->jobid);
    
    my @failures;
    while (my ($message) = $sth->fetchrow_array) {
        push @failures, $message;
    }
    return @failures;
}

sub failures {
    my $handle = shift;
    return scalar $handle->failure_log;
}

1;
__END__
