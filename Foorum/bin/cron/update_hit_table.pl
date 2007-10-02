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

use YAML qw(LoadFile);
use Foorum::ExternalUtils qw/schema/;
use Foorum::Log qw/error_log/;

# connect the db
my $schema = schema();

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

my @update_cols;
if ($hour == 1 and $min < 5) { # the first hour of today
    push @update_cols, ( hit_yesterday => \'hit_today', hit_today => \'hit_new' );
} else {
    push @update_cols, ( hit_today => \'hit_today + hit_new' ); #'
}
if ($wday == 1 and ($hour == 1 and $min < 5)) { # Monday
    push @update_cols, ( hit_weekly => \'hit_new' ); #'
} else {
    push @update_cols, ( hit_weekly => \'hit_weekly + hit_new' ); #'
}
if ($mday == 1 and ($hour == 1 and $min < 5)) { # The first day of the month
    push @update_cols, ( hit_monthly => \'hit_new' ); #'
} else {
    push @update_cols, ( hit_monthly => \'hit_monthly + hit_new' ); #'
}
    
$schema->resultset('Hit')->search()->update( {
    @update_cols,
} );
$schema->resultset('Hit')->search()->update( {
    hit_new => 0
} );

error_log($schema, 'info', "$0 - "  . dump(\@update_cols) . ' @ ' . localtime());

1;