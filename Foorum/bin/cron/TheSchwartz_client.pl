#!/usr/bin/perl

# crontab: */5 * * * * perl update_hit_table.pl

use strict;
use warnings;
use Schedule::Cron;

# for both Linux/Win32
my $has_proc_pid_file = eval "use Proc::PID::File; 1;";
if ($has_proc_pid_file) {
    # If already running, then exit
    if (Proc::PID::File->running()) {
        exit(0);
    }
}

use FindBin qw/$Bin/;
use lib "$Bin/../../lib";
use Foorum::ExternalUtils qw/theschwartz/;

my $client = theschwartz();

sub update_hit { # run every 5 minutes
    $client->insert('Foorum::TheSchwartz::Worker::Hit');
}

sub remove_old_data_from_db { # run everyday
    $client->insert('Foorum::TheSchwartz::Worker::RemoveOldDataFromDB');
}

my $cron =  new Schedule::Cron(sub { return 1;});
$cron->add_entry("*/5 * * * *", \&update_hit);
$cron->add_entry("1 0 * * *", \&remove_old_data_from_db);
$cron->run();

1;