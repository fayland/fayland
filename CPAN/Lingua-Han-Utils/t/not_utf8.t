#!perl -T

use Test::More tests => 1;

use Lingua::Han::Utils qw/Unihan_value/;

my $word = 'жа';

is(Unihan_value($word), '4E2D', "it's not under utf8");
