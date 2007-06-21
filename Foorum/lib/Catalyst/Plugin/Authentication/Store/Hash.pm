package Catalyst::Plugin::Authentication::Store::Hash;

use strict;
use warnings;

our $VERSION = '0.01';

use Catalyst::Plugin::Authentication::Store::Hash::Backend;

sub setup {
    my $c = shift;

    # default values
    $c->config->{authentication}{dbic}{user_field}     ||= 'username';
    $c->config->{authentication}{dbic}{password_field} ||= 'password';
    $c->config->{authentication}{dbic}{catalyst_user_class} ||=
        'Catalyst::Plugin::Authentication::Store::Hash::User';        

    $c->default_auth_store(
        Catalyst::Plugin::Authentication::Store::Hash::Backend->new( {
            auth  => $c->config->{authentication}{dbic},
        } )
    );

    $c->NEXT::setup(@_);
}

sub setup_finished {
    my $c = shift;

    return $c->NEXT::setup_finished unless @_;

    my $config = $c->default_auth_store;
    if (my $user_class = $config->{auth}{user_class}) {
        my $model = $c->model($user_class) || $c->comp($user_class);
        $config->{auth}{user_class} = ref $model ? $model
            : $user_class;
    }
    else {
        Catalyst::Exception->throw( message => "You must provide a user_class" );
    }

    $c->NEXT::setup_finished(@_);
}

sub user_object {
    my $c = shift;

    return ( $c->user_exists ) ? $c->user->obj : undef;
}

1;