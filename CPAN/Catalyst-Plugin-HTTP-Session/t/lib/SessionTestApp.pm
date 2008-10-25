#!/usr/bin/perl

package SessionTestApp;
use Catalyst qw/HTTP::Session/;

use strict;
use warnings;

__PACKAGE__->config->{http_session} = {
    store_class => 'HTTP::Session::Store::Test',
    state_class => 'HTTP::Session::State::URI',
    state => {
        session_id_name => 'foo_sid'
    }
};

sub counter : Global {
    my ( $self, $c ) = @_;
    
    my $counter = $c->session->get('counter') || 0;
    $c->log->error('sid ' . $c->session->session_id);
    $counter++;
    $c->session->set('counter', $counter);
    
    $c->res->output( $c->session->get('counter') );
}

__PACKAGE__->setup;

__PACKAGE__;

