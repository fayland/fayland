package Catalyst::Plugin::Authentication::Store::Hash::Backend;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

sub new {
    my ( $class, $config ) = @_;

    my $uc = $config->{auth}{catalyst_user_class};
    eval "require $uc";
    die $@ if $@;

    $config->{auth}{user_field} = [ $config->{auth}{user_field} ]
        if !ref $config->{auth}{user_field};

    bless { %{$config} }, $class;
}

sub from_session {
    my ( $self, $c, $id ) = @_;

    return $id if ref $id;

    # XXX: hits the database on every request?  Not good...
    return $self->get_user($id);
}

sub get_user {
    my ( $self, $id, @rest ) = @_;

    my $user = $self->{auth}{catalyst_user_class}->new( $id, { %{$self} } );

    if ($user) {
        $user->store($self);
        return $user;
    }
    return undef;
}

sub user_supports {

    # this can work as a class method
    shift->{auth}{catalyst_user_class}->supports(@_);
}

1;
