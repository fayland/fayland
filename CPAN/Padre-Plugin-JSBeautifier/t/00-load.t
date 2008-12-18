#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::JSBeautifier' );
}

diag( "Testing Padre::Plugin::JSBeautifier $Padre::Plugin::JSBeautifier::VERSION, Perl $], $^X" );
