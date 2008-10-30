#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'CatalystX::Example::OpenID' );
}

diag( "Testing CatalystX::Example::OpenID $CatalystX::Example::OpenID::VERSION, Perl $], $^X" );
