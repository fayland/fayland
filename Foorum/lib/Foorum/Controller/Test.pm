package Foorum::Controller::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub test : Global {
    my ( $self, $c ) = @_;
    
    if ( $c->login('fayland', '00000000') ) {
        $c->res->body('1');
    } else {
        $c->res->body('2');
    }
    return;
    use Data::Dumper;
    $c->res->body('OK'. Dumper($c->session->{test}));
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;