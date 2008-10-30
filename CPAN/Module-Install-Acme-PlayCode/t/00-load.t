#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Module::Install::Acme::PlayCode' );
}

diag( "Testing Module::Install::Acme::PlayCode $Module::Install::Acme::PlayCode::VERSION, Perl $], $^X" );
