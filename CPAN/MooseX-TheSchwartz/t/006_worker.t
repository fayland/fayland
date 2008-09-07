#!/usr/bin/perl

use strict;
use warnings;
use t::Utils;
use MooseX::TheSchwartz;

BEGIN {

    eval "use Test::Output;";
    plan skip_all => "Test::Output is required for this test" if $@;

};


plan tests => 1;

run_test {
    my $dbh = shift;
    my $sch = MooseX::TheSchwartz->new();
    $sch->databases([$dbh]);

    
};

# TODO
ok('a');

package Worker::Dummy;

use base 'MooseX::TheSchwartz::Worker';
sub work {
    my ($class, $job) = @_;
    
    
}

sub max_retries { 2 }
sub retry_delay { 5 }
