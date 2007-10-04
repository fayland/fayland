#!/usr/bin/perl

# crontab: */5 * * * * perl update_hit_table.pl

use strict;
use warnings;
use Data::Dump qw/dump/;
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
use Foorum::ExternalUtils qw/theschwartz/;

my $client = theschwartz();

$client->insert('Foorum::TheSchwartz::Worker::Hit'); # run every 5 minutes
$client->insert('Foorum::TheSchwartz::Worker::RemoveOldDataFromDB'); # run everyday

1;