#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MooseX::TheSchwartz' );
}

diag( "Testing MooseX::TheSchwartz $MooseX::TheSchwartz::VERSION, Perl $], $^X" );
