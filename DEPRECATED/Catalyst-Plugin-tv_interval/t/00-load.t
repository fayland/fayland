#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::tv_interval' );
}

diag( "Testing Catalyst::Plugin::tv_interval $Catalyst::Plugin::tv_interval::VERSION, Perl $], $^X" );
