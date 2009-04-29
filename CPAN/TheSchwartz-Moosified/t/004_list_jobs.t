use strict;
use warnings;
use t::Utils;
use TheSchwartz::Moosified;
plan tests => 40;

foreach $::prefix ("", "someprefix") {

run_test {
    my $dbh = shift;
    my $sch = TheSchwartz::Moosified->new();
    $sch->databases([$dbh]);
    $sch->prefix($::prefix) if $::prefix;

    $sch->insert('fetch', 'http://wassr.jp/');
    $sch->insert(
        TheSchwartz::Moosified::Job->new(
            funcname => 'fetch',
            arg      => 'http://pathtraq.com/',
            priority => 3,
        )
    );

    my @jobs = $sch->list_jobs( { funcname => 'fetch' } );

    my $row = $jobs[0];
    ok $row;
    is $row->jobid,    1;
    is $row->funcid,   $sch->funcname_to_id( $dbh, 'fetch' );
    is $row->arg,      'http://wassr.jp/';
    is $row->priority, undef;

    $row = $jobs[1];
    ok $row;
    is $row->jobid,    2;
    is $row->funcid,   $sch->funcname_to_id( $dbh, 'fetch' );
    is $row->arg,      'http://pathtraq.com/';
    is $row->priority, 3;
    
    # test priority
    my $sch2 = TheSchwartz::Moosified->new( databases => [ $dbh ], prioritize => 1 );
    
    $sch2->insert('fetch2', 'http://fayland.org/');
    $sch2->insert(
        TheSchwartz::Moosified::Job->new(
            funcname => 'fetch2',
            arg      => 'http://foorumbbs.com/',
            priority => 3,
        )
    );
    
    @jobs = $sch2->list_jobs({funcname => 'fetch2'});
    $row = $jobs[0];
    ok $row;
    is $row->jobid,    4;
    is $row->arg,      'http://foorumbbs.com/';
    is $row->priority, 3;

    $row = $jobs[1];
    ok $row;
    is $row->jobid,    3;
    is $row->arg,      'http://fayland.org/';
    is $row->priority, undef;
    
    # test funcname as arrayref
    # and test want_handle with ->funcname
    @jobs = $sch2->list_jobs( { funcname => ['fetch', 'fetch2'], want_handle => 1 } );
    is(scalar @jobs, 4, 'funcname is arrayref');
    $row = $jobs[0];
    is $row->funcname, 'fetch';
};

}