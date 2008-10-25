#!perl -T

use Test::More;
use HTTP::Session;
use HTTP::Session::State::Null;
use HTTP::Session::Store::DBI;

BEGIN {
    eval 'require DBD::SQLite';
    plan skip_all => 'this test requires DBD::SQLite' if $@;
    eval 'require File::Temp';
    plan skip_all => 'this test requires File::Temp' if $@;

    plan tests => 5;
};

my $tmp = File::Temp->new;
$tmp->close();
my $tmpf = $tmp->filename;
my $dbh = DBI->connect("dbi:SQLite:dbname=$tmpf", '', '', {RaiseError => 1}) or die $DBI::err;

my $SCHEMA = <<'SQL';
CREATE TABLE session (
        sid          VARCHAR(32) PRIMARY KEY,
        data         TEXT,
        expires      INTEGER UNSIGNED NOT NULL,
        UNIQUE(sid)
);
SQL

$dbh->begin_work;
$dbh->do($SCHEMA);
$dbh->commit;

my $store = HTTP::Session::Store::DBI->new(
    dbh => ["dbi:SQLite:dbname=$tmpf", '', '', {RaiseError => 1}]
);
my $key = "jklj352krtsfskfjlafkjl235j1" . rand();
is $store->select($key), undef;
$store->insert($key, {foo => 'bar'});
is $store->select($key)->{foo}, 'bar';
$store->update($key, {foo => 'replaced'});
is $store->select($key)->{foo}, 'replaced';
$store->delete($key);
is $store->select($key), undef;
ok $store;
