#!/usr/bin/perl

# daemon: perl send_scheduled_email.pl

use strict;
use warnings;
use Data::Dumper;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

use Proc::Daemon;
use Proc::PID::File;

# If already running, then exit
if (Proc::PID::File->running()) {
    exit(0);
}

use YAML qw(LoadFile);
use Foorum::Schema; # DB Schema

# load foorum.yml and foorum_local.yml
# and merge as $config
my $config = LoadFile("$Bin/../../foorum.yml");
my $extra_config = LoadFile("$Bin/../../foorum_local.yml");
$config = { %$config, %$extra_config };

# connect the db
my $schema = Foorum::Schema->connect(
    $config->{dsn},
    $config->{dsn_user},
    $config->{dsn_pwd},
    { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
);

# Daemonize
Proc::Daemon::Init();

while (1) {

    my $start_time = time();

    my $rs = $schema->resultset('ScheduledEmail')->search( { processed => 'N' } );
    
    while (my $rec = $rs->next) {
        
        print 'To: ' . $rec->to_email . ' Subject: ' . $rec->subject . "\n";
        send_email( $rec->from_email, $rec->to_email, $rec->subject, $rec->plain_body, $rec->html_body );
        
        # update processed
        $rec->update( { processed => 'Y' } );
    }
    
    my $end_time = time();

    if ($end_time - $start_time < 30) {
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