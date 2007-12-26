#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'CatalystX::Foorum' );
}

diag( "Testing CatalystX::Foorum $CatalystX::Foorum::VERSION, Perl $], $^X" );
