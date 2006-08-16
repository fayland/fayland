package Foorum::Controller::Utils;

use strict;
use warnings;
use base 'Catalyst::Controller';

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

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;