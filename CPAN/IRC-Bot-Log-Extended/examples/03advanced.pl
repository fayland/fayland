#!/usr/bin/perl -w

# for both Linux/Win32
my $has_proc_pid_file
    = eval "use Proc::PID::File; 1;";    ## no critic (ProhibitStringyEval)
my $has_home_dir
    = eval "use File::HomeDir; 1;";      ## no critic (ProhibitStringyEval)
if ( $has_proc_pid_file and $has_home_dir ) {

    # If already running, then exit
    if ( Proc::PID::File->running( { dir => File::HomeDir->my_home } ) ) {
        exit(0);
    }
}

package IRC::Bot::Log2;

use Moose;
extends 'IRC::Bot::Log::Extended';

use URI::Find;

augment pre_insert => sub {
    my ($self, $file_ref, $message_ref) = @_;
    
    # change filename
    $$file_ref .= '.html';
    
    # HTML-lize
    $$message_ref =~ s/\</\&lt\;/isg;
    
    # find URIs
    my $finder = URI::Find->new(
        sub {
            my ( $uri, $orig_uri ) = @_;
            return qq|<a href="$uri">$orig_uri</a>|;
        }
    );
    $finder->find( $message_ref );
    
    $$message_ref .= "</br>";
};

package IRC::Bot2;

use Moose;
extends 'IRC::Bot';

after 'bot_start' => sub {
    my $self = shift;

    no warnings; 
    $IRC::Bot::log =  IRC::Bot::Log2->new(
        Path          => $self->{'LogPath'},
        split_channel => 1,
        split_day     => 1,
    );
};

package main;

# Initialize new object
my $bot = IRC::Bot2->new(
    Debug    => 0,
    Nick     => 'Fayland_logger',
    Server   => 'irc.perl.org',
    Password => '',
    Port     => '6667',
    Username => 'Fayland_Logger',
    Ircname  => 'Fayland_Logger',
    Channels => [ '#fayland' ],
    LogPath  => '/home/fayland/root/irclog/',
    NSPass   => 'nickservpass'
);

# Daemonize process
$bot->daemon();

# Run the bot
$bot->run();

1;
