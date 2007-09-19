#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use YAML qw(LoadFile);
use lib "$Bin/../../../lib";

# load foorum.yml and foorum_local.yml
# and merge as $config
my $config = LoadFile("$Bin/../../../foorum.yml");
my $extra_config = LoadFile("$Bin/../../../foorum_local.yml");
$config = { %$config, %$extra_config };

use Foorum::Schema; # DB Schema

my $last_version    = 0;
my $lastest_version = $Foorum::Schema::VERSION;

if (-e 'last_version.txt') {
    open(my $fh, '<', 'last_version.txt');
    flock($fh, 2);
    $last_version = <$fh>;
    close($fh);
    chomp($last_version);
}

unless ($lastest_version > $last_version) {
    print "Already deployed, lastest: $lastest_version; last: $last_version";
    exit;
}

# connect the db
my $schema = Foorum::Schema->connect(
    $config->{dsn},
    $config->{dsn_user},
    $config->{dsn_pwd},
    { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
);

$schema->deploy({ add_drop_tables => 1});
$schema->create_ddl_dir(['MySQL', 'SQLite', 'PostgreSQL'],
    $lastest_version, '', $last_version
);

open(my $fh, '>', 'last_version.txt');
flock($fh, 2);
print $fh $lastest_version;
close($fh);

1;