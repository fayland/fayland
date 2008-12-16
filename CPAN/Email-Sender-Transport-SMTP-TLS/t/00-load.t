#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Email::Sender::Transport::SMTP::TLS' );
}

diag( "Testing Email::Sender::Transport::SMTP::TLS $Email::Sender::Transport::SMTP::TLS::VERSION, Perl $], $^X" );
