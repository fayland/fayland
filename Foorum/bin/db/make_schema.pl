#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin $RealBin/;
use YAML qw(LoadFile);
use Cwd qw/abs_path/;

use DBIx::Class::Schema::Loader qw| make_schema_at |;

my $path = abs_path("$RealBin/../../lib");
DBIx::Class::Schema::Loader->dump_to_dir($path);

# load foorum.yml and foorum_local.yml
# and merge as $config
my $config = LoadFile("$Bin/../../foorum.yml");
my $extra_config = LoadFile("$Bin/../../foorum_local.yml");
$config = { %$config, %$extra_config };

make_schema_at("Foorum::Schema", { debug => 1 }, [ $config->{dsn}, $config->{dsn_user}, $config->{dsn_pwd} ]);


1;