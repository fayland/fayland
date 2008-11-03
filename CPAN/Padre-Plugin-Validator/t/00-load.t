#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::Validator' );
}

diag( "Testing Padre::Plugin::Validator $Padre::Plugin::Validator::VERSION, Perl $], $^X" );
