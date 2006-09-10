package Foorum::Controller::Admin::Forum;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub auto : Private {
    my ($self, $c) = @_;

    # only administrator is allowed. site moderator is not allowed here
    return 0 unless ( $c->controller('Policy')->is_admin( $c, 'site' ) );
    return 1;
}

sub create : Local {
    my ( $self, $c ) = @_;
    
    $c->stash( {
        template => 'admin/forum/create.html',
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;