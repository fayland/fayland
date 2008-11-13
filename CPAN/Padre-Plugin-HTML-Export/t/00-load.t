#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::HTML::Export' );
}

diag( "Testing Padre::Plugin::HTML::Export $Padre::Plugin::HTML::Export::VERSION, Perl $], $^X" );
