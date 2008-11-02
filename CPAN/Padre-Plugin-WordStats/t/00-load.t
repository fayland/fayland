#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::WordStats' );
}

diag( "Testing Padre::Plugin::WordStats $Padre::Plugin::WordStats::VERSION, Perl $], $^X" );
