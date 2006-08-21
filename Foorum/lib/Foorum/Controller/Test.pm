package Foorum::Controller::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub test : Global {
    my ( $self, $c ) = @_;

    $c->log->debug('debug');
    $c->log->info('info');
    $c->log->error('error');
    $c->log->fatal('fatal');
    
    use Data::Dumper;
    $c->res->body('OK'. Dumper($c->config));
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;