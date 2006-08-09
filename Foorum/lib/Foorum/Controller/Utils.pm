package Foorum::Controller::Utils;

use strict;
use warnings;
use base 'Catalyst::Controller';
use HTML::Scrubber;
use vars qw/$scrubber/;

$scrubber = HTML::Scrubber->new( 
    allow => [ qw[ p b i u hr br font s span div ] ],
    deny  => [ qw[ script style ] ],
);

__PACKAGE__->config->{namespace} = '';

sub print_message : Private {
    my ($self, $c, $msg) = @_;
    
    if (ref($msg) ne 'HASH') {
        $msg = {
            msg => $msg,
        };
    }
    
    $c->stash->{message}  = $msg;
    $c->stash->{template} = 'simple/message.html';
}

sub print_error : Private {
    my ( $self, $c, $error ) = @_;

    if (ref($error) ne 'HASH') {
        $error = {
            msg => $error,
        };
    }
    
    $c->stash->{error}    = $error;
    $c->stash->{template} = 'simple/error.html';
}

sub html_scrubber : Private {
    my ( $self, $c, $html ) = @_;
    
    $html = $scrubber->scrub($html);
    
    return $html;
}

1;