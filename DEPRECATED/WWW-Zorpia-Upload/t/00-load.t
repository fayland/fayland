#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Zorpia::Upload' );
}

diag( "Testing WWW::Zorpia::Upload $WWW::Zorpia::Upload::VERSION, Perl $], $^X" );
