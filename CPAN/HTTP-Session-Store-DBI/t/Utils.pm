package t::Utils;
use strict;
use warnings;
use base qw/Exporter/;
use Test::More;
use DBI;
our @EXPORT = (@Test::More::EXPORT, 'run_test');

eval 'require DBD::SQLite';
plan skip_all => 'this test requires DBD::SQLite' if $@;
eval 'require File::Temp';
plan skip_all => 'this test requires File::Temp' if $@;

my $SCHEMA = join '', <DATA>;

sub run_test (&) {
    my $code = shift;
    my $tmp = File::Temp->new;
    $tmp->close();
    my $tmpf = $tmp->filename;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$tmpf", '', '', {RaiseError => 1}) or die $DBI::err;

    # work around for DBD::SQLite's resource leak
    tie my %blackhole, 't::Utils::Blackhole';
    $dbh->{CachedKids} = \%blackhole;

    do {
        $dbh->begin_work;
        for (split /;\s*/, $SCHEMA) {
            $dbh->do($_);
        }
        $dbh->commit;
    };

    $code->($dbh); # do test

    $dbh->disconnect;
}

{
    package t::Utils::Blackhole;
    use base qw/Tie::Hash/;
    sub TIEHASH { bless {}, shift }
    sub STORE { } # nop
    sub FETCH { } # nop
}

1;
__DATA__
CREATE TABLE session (
        sid          INTEGER PRIMARY KEY,
        data         MEDIUMBLOB,
        expires      INTEGER UNSIGNED NOT NULL,
        UNIQUE(sid)
);
