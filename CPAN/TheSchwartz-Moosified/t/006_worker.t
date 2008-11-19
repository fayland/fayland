#!/usr/bin/perl

use strict;
use warnings;
use t::Utils;
use TheSchwartz::Moosified;

BEGIN {

    eval "use Test::Output;";
    plan skip_all => "Test::Output is required for this test" if $@;

};


plan tests => 1;

run_test {
    my $dbh = shift;
    my $sch = TheSchwartz::Moosified->new();
    $sch->databases([$dbh]);

    
};

# TODO
ok('a');

package Worker::Dummy;

use base 'TheSchwartz::Moosified::Worker';
sub work {
    my ($class, $job) = @_;
    
    
}

sub max_retries { 2 }
sub retry_delay { 5 }
