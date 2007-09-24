#!/usr/bin/perl

# crontab: 0 * * * * perl remove_session_dbic.pl

use strict;
use warnings;
use Data::Dumper;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

# for both Linux/Win32
my $has_proc_pid_file = eval "use Proc::PID::File; 1;";
if ($has_proc_pid_file) {
    # If already running, then exit
    if (Proc::PID::File->running()) {
        exit(0);
    }
}

use YAML qw(LoadFile);
use Foorum::ExternalUtils qw/schema/;
use Foorum::Log qw/error_log/;

# connect the db
my $schema = schema();

# 2592000 = 30 * 24 * 60 * 60
my $status = $schema->resultset('Session')->search( {
    expires => { '<', time() },
} )->delete;

error_log($schema, 'info', "$0 - status: $status");

1;