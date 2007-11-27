package Foorum::TheSchwartz::Worker::DailyChart;

use TheSchwartz::Job;
use base qw( TheSchwartz::Worker );
use Foorum::ExternalUtils qw/schema/;
use Foorum::Log qw/error_log/;

sub work {
    my $class = shift;
    my TheSchwartz::Job $job = shift;
    
    my @args = $job->arg;
    
    my $schema = schema();

    register_stat($schema, 'User');
    register_stat($schema, 'Comment');
    register_stat($schema, 'Forum');
    register_stat($schema, 'Topic');
    register_stat($schema, 'Message');

    $job->completed();
}

sub register_stat {
    my ($schema, $table) = @_;
    
    my $stat_value = $schema->resultset($table)->count();
    
    my $stat_key = 'count_' . lc($table);
    
    my $dbh = $schema->storage->dbh;
    
    my $sql = q~SELECT COUNT(*) FROM stat WHERE stat_key = ? AND date = NOW()~;
    my $sth = $dbh->prepare($sql);
    $sth->execute($stat_key);
    
    my ($count) = $sth->fetchrow_array;
    
    unless ($count) {
        $sql = q~INSERT INTO stat SET stat_key = ?, stat_value = ?, date = NOW()~;
    } else {
        $sql = q~UPDATE stat SET stat_key = ?, date = NOW() WHERE stat_value = ?~;
    }
    $sth = $dbh->prepare($sql);
    $sth->execute($stat_key, $stat_value);
    
}

1;