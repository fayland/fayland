#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::UpLowCase' );
}

diag( "Testing Padre::Plugin::UpLowCase $Padre::Plugin::UpLowCase::VERSION, Perl $], $^X" );
