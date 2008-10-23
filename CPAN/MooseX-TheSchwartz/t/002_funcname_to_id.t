use strict;
use warnings;
use t::Utils;
use MooseX::TheSchwartz;

plan tests => 6;

run_test {
    my $dbh1 = shift;
    run_test {
        my $dbh2 = shift;

        my $sch = MooseX::TheSchwartz->new();
        $sch->databases([$dbh1, $dbh2]);
        isa_ok $sch, 'MooseX::TheSchwartz';
        is $sch->funcname_to_id($dbh1, 'foo'), 1;
        is $sch->funcname_to_id($dbh1, 'bar'), 2;
        is $sch->funcname_to_id($dbh1, 'foo'), 1;
        is $sch->funcname_to_id($dbh1, 'baz'), 3;
        is $sch->funcname_to_id($dbh2, 'bar'), 1, 'other dbh';
    };
};

