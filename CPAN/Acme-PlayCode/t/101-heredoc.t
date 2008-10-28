#!perl -T

use strict;
use Test::More tests => 1;

use Acme::PlayCode;

my $from = <<'FROM';
my $a = <<'GG';
AAAAAAAAAAAbbbb
GG
my $b = <<HH;
sadsd
sadsad
HH
FROM

my $to = <<'TO';
my $a = <<'GG';
AAAAAAAAAAAbbbb
GG
my $b = <<HH;
sadsd
sadsad
HH
TO

my $app = Acme::PlayCode->new();
$app->load_plugin('Averything');
my $ret = $app->play($from);

is($ret, $to, '1 ok');
