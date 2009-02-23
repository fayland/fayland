#!perl -T

use Test::More tests => 1;

use MooseX::Dumper;

my $dumper = MooseX::Dumper->new_with_traits( traits => ['HTML']);

my $hash = { a => 1, b => 3 };

my $ret = $dumper->Dumper(\$hash);

is $ret, <<'EOF';
$VAR1 = \{<br />
&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; 'a' =&gt; 1,<br />
&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; 'b' =&gt; 3<br />
&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;};<br />
EOF

1;