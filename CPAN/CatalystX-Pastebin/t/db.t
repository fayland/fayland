#!/usr/bin/perl

use Test::More;

BEGIN {
    $ENV{Catalyst_Pastebin_Test}
        or plan skip_all => "set Catalyst_Pastebin_Test to enable this test";
    plan tests => 2;
}

use FindBin qw/$Bin/;
use CatalystX::Pastebin::Schema;

my $schema
        = CatalystX::Pastebin::Schema->connect( "dbi:SQLite:$Bin/pastebin.sqlite", '', '',
        { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
        );

my $rs = $schema->resultset('Pastebin')->create( {
    id => 'testme',
    text => 'testtest'
} );
isnt($rs, undef, 'create OK');
is($rs->id, 'testme', 'create id OK');

$schema->resultset('Pastebin')->search( {
    id => 'testme',
} )->delete;

END {
    use File::Copy qw/copy/;
    copy("$Bin/pastebin.sqlite.backup", "$Bin/pastebin.sqlite");
}

1;
