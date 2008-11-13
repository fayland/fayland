#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::Tidy' );
}

diag( "Testing Padre::Plugin::Tidy $Padre::Plugin::Tidy::VERSION, Perl $], $^X" );
