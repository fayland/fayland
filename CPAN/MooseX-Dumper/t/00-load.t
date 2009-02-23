#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MooseX::Dumper' );
}

diag( "Testing MooseX::Dumper $MooseX::Dumper::VERSION, Perl $], $^X" );
