#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::CHI' );
}

diag( "Testing Catalyst::Plugin::CHI $Catalyst::Plugin::CHI::VERSION, Perl $], $^X" );
