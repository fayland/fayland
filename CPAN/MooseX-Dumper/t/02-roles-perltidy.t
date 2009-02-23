#!perl -T

use Test::More tests => 1;

use MooseX::Dumper;

my $dumper = MooseX::Dumper->new_with_traits( traits => ['Perltidy']);

my $hash = { a => 1, b => 3 };

my $ret = $dumper->Dumper(\$hash);

is $ret, <<'EOF';
$VAR1 = \{
    'a' => 1,
    'b' => 3
};
EOF

1;