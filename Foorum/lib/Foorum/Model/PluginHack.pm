package Foorum::Model::PluginHack;

use strict;
use warnings;
use base 'Catalyst::Model';

sub search {
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

package Catalyst::Plugin::Authentication::Store::DBIC::User;

no warnings 'redefine';

sub new {
    my ( $class, $id, $config ) = @_;

    my $query = @{$config->{auth}{user_field}} > 1
        ? { -or => [ map { { $_ => $id } } @{$config->{auth}{user_field}} ] }
        : { $config->{auth}{user_field}[0] => $id };

    # this line is changed!!!!!!!!!!!!
    my $user_obj = $config->{auth}{user_class}->search($query); # ->first is chomped
    return unless $user_obj;

    bless {
        id     => $id,
        config => $config,
        obj    => $user_obj,
    }, $class;
}

sub AUTOLOAD {
    my $self = shift;
    (my $method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method eq "DESTROY";

    $self->obj->{$method}; # that's hash then
}

1;