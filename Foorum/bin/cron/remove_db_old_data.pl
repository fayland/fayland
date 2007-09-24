#!/usr/bin/perl

# crontab: 0 0 * * * perl remove_db_old_data.pl

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

my $cron_config = LoadFile("$Bin/../../conf/cron.yml");

# connect the db
my $schema = schema();

# for table 'visit'
# 2592000 = 30 * 24 * 60 * 60
my $old_time = $cron_config->{remove_db_old_data}->{visit} || 2592000;
my $visit_status = $schema->resultset('Visit')->search( {
    time => { '<', time() - $old_time }
} )->delete;

# for table 'log_path'
my $days_ago = $cron_config->{remove_db_old_data}->{log_path} || 30;
my $log_path_status = $schema->resultset('LogPath')->search( {
    time => \"< DATE_SUB(NOW(), INTERVAL $days_ago DAY)",
} )->delete;

# for table 'log_error'
$days_ago = $cron_config->{remove_db_old_data}->{log_error} || 30;
my $log_error_status = $schema->resultset('LogError')->search( {
    time => \"< DATE_SUB(NOW(), INTERVAL $days_ago DAY)",
} )->delete;

# for table 'banned_ip'
$days_ago = $cron_config->{remove_db_old_data}->{banned_ip} || 604800;
my $banned_ip_status = $schema->resultset('BannedIp')->search( {
    time => { '<' , time() - $days_ago },
} )->delete;

error_log($schema, 'info', <<LOG);
$0 - status:
    visit - $visit_status
    log_path - $log_path_status
    log_error - $log_error_status
    banned_ip - $banned_ip_status
LOG

1;