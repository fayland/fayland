#!perl -T

use Test::More tests => 1;

use Lingua::Han::Utils qw/Unihan_value/;

my $word = "中";

is(Unihan_value($word), '4E2D', "it's under utf8");
