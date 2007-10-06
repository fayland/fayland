#!/usr/bin/perl

use strict;
use warnings;

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
    debug('update_hit');
    $client->insert('Foorum::TheSchwartz::Worker::Hit');
}
sub remove_old_data_from_db { # run everyday
    debug('remove_old_data_from_db');
    $client->insert('Foorum::TheSchwartz::Worker::RemoveOldDataFromDB');
}
sub daily_report {
    debug('daily_report');
    $client->insert('Foorum::TheSchwartz::Worker::DailyReport');
}

use Schedule::Cron;
my $cron =  new Schedule::Cron(sub { return 1; });
$cron->add_entry("*/5 * * * *", \&update_hit);
$cron->add_entry("10 3 * * *",  \&remove_old_data_from_db);
$cron->add_entry("0 0 * * *",   \&daily_report);
$cron->run();

sub debug {
    my ($msg) = @_;
    
    print "$msg \@" . localtime() . "\n";
}

1;