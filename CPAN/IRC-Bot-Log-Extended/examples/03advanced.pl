#!/usr/bin/perl -w

package IRC::Bot::Log2;

use Moose;
extends 'IRC::Bot::Log::Extended';

use URI::Find;

augment pre_insert => sub {
    my ($self, $file_ref, $message_ref) = @_;
    
    # change filename
    $$file_ref .= '.html';
    
    # HTML-lize
    
    # find URIs
    my $finder = URI::Find->new(
        sub {
            my ( $uri, $orig_uri ) = @_;
            return qq|<a href="$uri">$orig_uri</a>|;
        }
    );
    $finder->find( \$message_ref );
    
    $$message_ref .= "</br>\n";
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
