#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Padre::Plugin::PluginHelper' );
}

diag( "Testing Padre::Plugin::PluginHelper $Padre::Plugin::PluginHelper::VERSION, Perl $], $^X" );
