#!perl -T

use Test::More tests => 8;
use Test::Exception;

use MooseX::Types::IO::All;
use FindBin qw/$Bin/;

use Moose::Util::TypeConstraints;
isa_ok( find_type_constraint('IO::All'), "Moose::Meta::TypeConstraint" );

{
    {
        package Foo;
        use Moose;

        has io => (
            isa => "IO::All",
            is  => "rw",
            coerce => 1,
        );
    }

    my $str = "test for IO::All\n line 2";
    my $coerced = Foo->new( io => \$str )->io;

    isa_ok( $coerced, "IO::All", "coerced IO::All" );
    ok( $coerced->can('print'), "can print" );
    is( ${ $coerced->string_ref }, $str, 'get string');
    
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
    isa_ok( $coerced2, "IO::All", "coerced IO::All" );
    ok( $coerced2->can('print'), "can print" );
    is( $coerced2->all, $str2, 'get string');

    throws_ok { Foo->new( io => [\$str2] ) } qr/IO\:\:All/, "constraint";
}


