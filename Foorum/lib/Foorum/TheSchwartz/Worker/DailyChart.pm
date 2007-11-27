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
    
    my $count = $schema->resultset($table)->count();
    
    my $key = 'count_' . lc($table);
    $schema->resultset('Stat')->create( {
        stat_key   => $key,
        stat_value => $count,
        date  => \'NOW()',
    } );
}

1;