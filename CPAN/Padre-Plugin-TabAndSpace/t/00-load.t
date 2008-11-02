#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::TabAndSpace' );
}

diag( "Testing Padre::Plugin::TabAndSpace $Padre::Plugin::TabAndSpace::VERSION, Perl $], $^X" );
