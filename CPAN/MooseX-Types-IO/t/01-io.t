#!perl -T

use Test::More tests => 9;

use MooseX::Types::IO;
use FindBin qw/$Bin/;

{
    {
        package Foo;
        use Moose;

        has io => (
            isa => "IO",
            is  => "rw",
            coerce => 1,
        );
    }

    my $str = "test for IO::String\n line 2";
    my $coerced = Foo->new( io => \$str )->io;

    isa_ok( $coerced, "IO::String", "coerced IO::String" );
    ok( $coerced->can('print'), "can print" );
    is(do { local $/; <$coerced> }, $str, 'get string');
    
    my $filename = "$Bin/00-load.t";
    my $str2 = <<'FC';
#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MooseX::Types::IO' );
}

diag( "Testing MooseX::Types::IO $MooseX::Types::IO::VERSION, Perl $], $^X" );
FC
    my $coerced2 = Foo->new( io => $filename )->io;
    isa_ok( $coerced2, "IO::File", "coerced IO::File" );
    ok( $coerced2->can('print'), "can print" );
    is(do { local $/; <$coerced2> }, $str2, 'get string');
    
    open(my $fh, '<', $filename);
    my $coerced3 = Foo->new( io => [ $fh, '<' ] )->io;
    isa_ok( $coerced3, "IO::Handle", "coerced IO::Handle" );
    ok( $coerced3->can('print'), "can print" );
    is(do { local $/; <$coerced3> }, $str2, 'get string');
}


