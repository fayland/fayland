#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'XML::HARef' );
}

diag( "Testing XML::HARef $XML::HARef::VERSION, Perl $], $^X" );
