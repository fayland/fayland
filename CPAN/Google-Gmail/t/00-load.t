#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Google::Gmail' );
}

diag( "Testing Google::Gmail $Google::Gmail::VERSION, Perl $], $^X" );
