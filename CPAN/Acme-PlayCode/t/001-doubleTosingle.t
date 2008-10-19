#!perl -T

use strict;
use Test::More tests => 1;

use Acme::PlayCode;

my $from = <<'FROM';
my $a = "a";
my $b = "'b'";
my $c = qq~c~;
my $d = qq~'d'~;
my $e = q{e};
my $f = 'f';
if ( $a eq "a" ) {
    print "ok";
}
FROM

my $to = <<'TO';
my $a = 'a';
my $b = q~'b'~;
my $c = 'c';
my $d = qq~'d'~;
my $e = q{e};
my $f = 'f';
if ( $a eq 'a' ) {
    print 'ok';
}
TO

my $app = Acme::PlayCode->new( io => \$from );
$app->load_plugin('DoubleToSingle');
my $ret = $app->run;

is($ret, $to, '1 ok');
