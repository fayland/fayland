#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Zorpia::Journal' );
}

diag( "Testing WWW::Zorpia::Journal $WWW::Zorpia::Journal::VERSION, Perl $], $^X" );
