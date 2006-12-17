package Foorum::Controller::Cron;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub begin : Private {
    my ($self, $c) = @_;
    
    $c->res->body('Cron is running');
}

sub remove_sessions : Local {
    my ( $self, $c ) = @_;
    
    $c->delete_expired_sessions;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
