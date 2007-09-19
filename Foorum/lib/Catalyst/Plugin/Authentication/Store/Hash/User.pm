package Catalyst::Plugin::Authentication::Store::Hash::User;

use strict;
use warnings;
use base qw/Catalyst::Plugin::Authentication::User Class::Accessor::Fast/;
use Set::Object ();

use overload '""' => sub { shift->id }, 'bool' => sub {1}, fallback => 1;

__PACKAGE__->mk_accessors(qw/id config obj store/);

sub new {
    my ( $class, $id, $config ) = @_;

    my $query = @{ $config->{auth}{user_field} } > 1
        ? {
        -or => [
            map {
                { $_ => $id }
                } @{ $config->{auth}{user_field} }
        ]
        }
        : { $config->{auth}{user_field}[0] => $id };

    my $user_obj = $config->{auth}{user_class}->get_user($query);
    return unless $user_obj;

    bless {
        id     => $id,
        config => $config,
        obj    => $user_obj,
    }, $class;
}

*user             = \&obj;
*crypted_password = \&password;
*hashed_password  = \&password;

sub hash_algorithm { shift->config->{auth}{password_hash_type} }

sub password_pre_salt { shift->config->{auth}{password_pre_salt} }

sub password_post_salt { shift->config->{auth}{password_post_salt} }

sub password_salt_len { shift->config->{auth}{password_salt_len} }

sub password {
    my $self = shift;

    return undef unless defined $self->obj;
    my $password_field = $self->config->{auth}{password_field};
    return $self->obj->{$password_field};
}

sub supported_features {
    my $self = shift;
    $self->config->{auth}{password_type} ||= 'clear';

    return {
        password => { $self->config->{auth}{password_type} => 1, },
        session  => 1,
        session_data => $self->{config}{auth}{session_data_field} ? 1 : 0,
        roles => 0,
    };
}

sub get_session_data {
    my ($self) = @_;
    my $col = $self->config->{auth}{session_data_field};
    return $self->obj->{$col};
}

sub for_session {
    shift->id;
}

sub AUTOLOAD {
    my $self = shift;
    ( my $method ) = ( our $AUTOLOAD =~ /([^:]+)$/ );
    return if $method eq "DESTROY";

    $self->obj->{$method};
}

1;
