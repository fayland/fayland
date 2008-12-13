#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MojoX::Fixup::XHTML' );
}

diag( "Testing MojoX::Fixup::XHTML $MojoX::Fixup::XHTML::VERSION, Perl $], $^X" );
