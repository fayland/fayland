#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use FindBin qw/$Bin/;

my $dbh = DBI->connect("dbi:SQLite:$Bin/../pastebin.sqlite", '', '');
my $sql = <<'SQL';
CREATE TABLE `pastebin` (`id` CHAR PRIMARY KEY  NOT NULL , `text` TEXT NOT NULL );
SQL
$dbh->do($sql) or die $DBI::errstr;

print "OK\n";
