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
use Foorum::TheSchwartz::Worker::Hit;
use Foorum::TheSchwartz::Worker::RemoveOldDataFromDB;
use Foorum::TheSchwartz::Worker::ResizeProfilePhoto;

my $client = theschwartz();
$client->can_do('Foorum::TheSchwartz::Worker::Hit');
$client->can_do('Foorum::TheSchwartz::Worker::RemoveOldDataFromDB');
$client->can_do('Foorum::TheSchwartz::Worker::ResizeProfilePhoto');
$client->work();

1;