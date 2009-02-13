#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Task::Fayland' );
}

diag( "Testing Task::Fayland $Task::Fayland::VERSION, Perl $], $^X" );
