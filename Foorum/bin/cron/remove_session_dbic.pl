#!/usr/bin/perl

# crontab: 0 * * * * perl remove_session_dbic.pl

use strict;
use warnings;
use Data::Dumper;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

use YAML qw(LoadFile);
use Foorum::Schema; # DB Schema

# load foorum.yml and foorum_local.yml
# and merge as $config
my $config = LoadFile("$Bin/../../foorum.yml");
my $extra_config = LoadFile("$Bin/../../foorum_local.yml");
$config = { %$config, %$extra_config };

# connect the db
my $schema = Foorum::Schema->connect(
    $config->{dsn},
    $config->{dsn_user},
    $config->{dsn_pwd},
    { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
);

# 2592000 = 30 * 24 * 60 * 60
my $status = $schema->resultset('Session')->search( {
    expires => { '<', time() },
} )->delete;

print "$0 - status: $status \@ " . localtime() . "\n";