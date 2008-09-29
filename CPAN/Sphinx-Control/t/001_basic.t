#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use FindBin qw/$Bin/;

BEGIN {
    use_ok('Sphinx::Control');
}

my $ctl = Sphinx::Control->new(
    config_file => [qw[ t conf sphinx.conf ]],
    pid_file    => "$Bin/sphinx.control.pid", # this doesn't work on < 0.7.04
);
isa_ok($ctl, 'Sphinx::Control');

SKIP: {
    
skip "No Sphinx installed (or at least none found), why are you testing this anyway?", 4 
    unless eval { $ctl->binary_path };

ok(!$ctl->is_server_running, '... the server process is not yet running');

$ctl->start;

diag "Wait a moment for Sphinx to start";
sleep(2);

ok($ctl->is_server_running, '... the server process is now running');

$ctl->stop;

diag "Wait a moment for Sphinx to stop";
sleep(2);

ok(!-e $ctl->pid_file, '... PID file has been removed by Sphinx');
ok(!$ctl->is_server_running, '... the server process is no longer running');

}