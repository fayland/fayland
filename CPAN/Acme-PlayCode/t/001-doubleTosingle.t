#!perl -T

use strict;
use Test::More tests => 1;

use Acme::PlayCode;

my $str = 'my $a = "a";';

my $app = Acme::PlayCode->new( io => \$str );
$app->load_plugin('DoubleToSingle');
my $ret = $app->run;

is($ret, q~my $a = 'a';~, '1 ok');
