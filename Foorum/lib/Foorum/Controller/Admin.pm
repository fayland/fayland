package Foorum::Controller::Admin;

use strict;
use warnings;
use base 'Catalyst::Controller';
use YAML::Syck;
use Data::Dumper;

sub auto : Private {
    my ($self, $c) = @_;
    
    $c->stash( {
        no_online_view => 1, # avoid another connection of database for Admin.
#        no_url_referer => 1,
    } );
    
    return 0 unless ($c->user_exists);
    # we have admin or moderator for 'site' field
    return 0 unless ( $c->controller('Policy')->is_moderator( $c, 'site' ) );
    return 1;
}

sub default : Private {
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'admin/index.html';
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
