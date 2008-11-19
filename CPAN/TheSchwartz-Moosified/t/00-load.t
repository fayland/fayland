#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'TheSchwartz::Moosified' );
}

diag( "Testing TheSchwartz::Moosified $TheSchwartz::Moosified::VERSION, Perl $], $^X" );
