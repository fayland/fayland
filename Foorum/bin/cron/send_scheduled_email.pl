#!/usr/bin/perl

# daemon: perl send_scheduled_email.pl

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

# for both Win32/Linux
my $has_proc_daemon = eval "use Proc::Daemon; 1;";
# Daemonize
Proc::Daemon::Init() if ($has_proc_daemon);

while (1) {

    my $start_time = time();

    my $rs = $schema->resultset('ScheduledEmail')->search( { processed => 'N' } );
    
    my $handled = 0;
    while (my $rec = $rs->next) {
        
        print 'To: ' . $rec->to_email . ' Subject: ' . $rec->subject . "\n";
        send_email( $rec->from_email, $rec->to_email, $rec->subject, $rec->plain_body, $rec->html_body );
        
        # update processed
        $rec->update( { processed => 'Y' } );
        $handled++;
    }
    
    my $cost_time = time() - $start_time;
    
    if ($handled) {
        error_log($schema, 'info', "$0 - sent: $handled");
    }

    if ($cost_time < 30) {
        sleep 30;
    } else {
        sleep 5;
    }
}

use MIME::Entity;
use Mail::Mailer qw(sendmail);

sub send_email {
    my ($from, $to, $subject, $plain_body, $html_body) = @_;
    
    my $top = MIME::Entity->build(
        'X-Mailer' => undef,    # remove X-Mailer tag in header
        'Type'     => "multipart/alternative",
        'Reply-To' => $from,
        'From'     => $from,
        'To'       => $to,
        'Subject'  => $subject,
    );

    $top->attach(
		Encoding => '7bit',
        Type 	 => 'text/plain',
        Charset  => 'utf-8',
        Data	 => $plain_body,
	);
    
    if ($html_body) {
    	$top->attach(
    		Type 	 => 'text/html',
    		Encoding => '7bit',
    		Charset	 => 'utf-8',
    		Data => $html_body,
    	);
    }

    my $headers;
	# read all headers' info , and set them into a hash
	foreach ($top->head->tags) {
		$headers->{$_} = $top->head->get($_);
	}
	$headers->{'Z-To'} = $to if ($to =~ /aol\.com/);
	my $body = $top->stringify_body;

    my $mailer = new Mail::Mailer;
    $mailer->open($headers);
	print $mailer $body;
	$mailer->close;
}

1;