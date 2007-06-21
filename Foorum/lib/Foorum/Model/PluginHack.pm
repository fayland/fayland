package Foorum::Model::PluginHack;

use strict;
use warnings;
use base 'Catalyst::Model';

sub get_user {
    my $self = shift;

    my $c = ${ Foorum->config->{user_auth} };
    my $user = $c->model('User')->get( $c, @_ );
    
    return $user;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;