package Foorum::Model::User;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub get_user_id_from_username {
    my ($self, $c, $username) = @_;
    
    my $rs = $c->model('DBIC::User')->find( {
        username => $username,
    }, {
        columns  => ['user_id'],
    } );
    return unless ($rs);
    return $rs->user_id;
}

sub get_username_from_user_id {
    my ($self, $c, $user_id) = @_;
    
    my $rs = $c->model('DBIC::User')->find( {
        user_id => $user_id,
    }, {
        columns  => ['username'],
    } );
    return unless ($rs);
    return $rs->username;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
