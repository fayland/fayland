#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::HTTP::Session' );
}

diag( "Testing Catalyst::Plugin::HTTP::Session $Catalyst::Plugin::HTTP::Session::VERSION, Perl $], $^X" );
