#!/usr/bin/perl

package SessionTestApp;

use strict;
use warnings;

use Catalyst qw/HTTP::Session/;

use DBI;
use File::Temp;
use HTTP::Session::Store::DBI;

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

my $sid1 = 'f2c001214aed8ee44496e1b742613901';
my $sid2 = '266f0f877adb171b46506cb4aeb817f7';

my $store = HTTP::Session::Store::DBI->new(
    dbh => $dbh
);
$store->insert($sid1, {foo => 'bar'});
$store->insert($sid2, {foo => 'bar'});

__PACKAGE__->config->{http_session} = {
    store_class => 'HTTP::Session::Store::DBI',
    state_class => 'HTTP::Session::State::URI',
    state => {
        session_id_name => 'foo_sid'
    },
    store => {
        dbh => $dbh
    }
};

sub counter : Global {
    my ( $self, $c ) = @_;
    
    my $counter = $c->session->{counter} || 0;
    $counter++;
    $c->session->{counter} = $counter;
    
    $c->res->output( $c->session->{counter} );
}

__PACKAGE__->setup;

__PACKAGE__;

