#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::DBIC::QueryLog' );
}

diag( "Testing Catalyst::Plugin::DBIC::QueryLog $Catalyst::Plugin::DBIC::QueryLog::VERSION, Perl $], $^X" );
