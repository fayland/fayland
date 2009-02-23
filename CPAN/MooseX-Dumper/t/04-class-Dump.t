#!perl -T

use Test::More;

BEGIN {

    my $has = eval "use Data::Dump; 1;";
    $has or plan skip_all =>
        "Data::Dump is required for this test";

    plan tests => 1;
};

use MooseX::Dumper;

my $dumper = MooseX::Dumper->new( dumper_class => 'Data::Dump' );

my @a = (1, [2, 3], {4 => 5});

my $ret = $dumper->Dumper(@a);

is $ret, '(1, [2, 3], { 4 => 5 })';

1;