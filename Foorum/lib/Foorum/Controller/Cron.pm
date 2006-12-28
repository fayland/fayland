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

sub remove_visits : Local {
    my ($self, $c) = @_;
    
    # 2592000 = 30 * 24 * 60 * 60
    $c->model('Visit')->remove_records_for_cron($c, 2592000);
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
