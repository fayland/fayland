package Foorum::Model::Policy;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub fill_user_role {
    my ( $self, $c, $field ) = @_;
    
    my @field = ('site'); # 'site' means site-cross Administrator
    push @field, $field if ($field and $field ne 'site');
    my @roles = $c->model('DBIC')->resultset('UserRole')->search( {
        user_id => $c->user->user_id,
        field   => \@field,
    } )->all;
    
    my $roles;
    foreach (@roles) {
        $roles->{$_->field}->{$_->role} = 1;
    }
    
    if ($roles->{$field}->{user}) {
        $roles->{is_member} = 1;
    }
    
    if ($roles->{site}->{moderator} || $roles->{$field}->{moderator}) {
        $roles->{is_member} = 1;
        $roles->{is_moderator} = 1;
    }
    
    if ($roles->{site}->{admin} || $roles->{$field}->{admin}) {
        $roles->{is_member} = 1;
        $roles->{is_moderator} = 1;
        $roles->{is_admin} = 1;
    }
    
    if ($roles->{$field}->{blocked}) {
        $roles->{is_member} = 0;
        $roles->{is_blocked} = 1;
    }
    
    $c->stash->{roles} = $roles;
}

sub is_admin {
    my ( $self, $c, $field ) = @_;
    
    $field = 'site' unless ($field);
    &fill_user_role( $self, $c, $field ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_admin};
}

sub is_moderator {
    my ( $self, $c, $field ) = @_;

    $field = 'site' unless ($field);
    &fill_user_role( $self, $c, $field ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_moderator};
}

sub is_user {
    my ( $self, $c, $field ) = @_;
    
    $field = 'site' unless ($field);
    &fill_user_role( $self, $c, $field ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_member};
}

sub is_blocked {
    my ($self, $c, $field ) = @_;
    
    $field = 'site' unless ($field);
    &fill_user_role( @_ ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_blocked};
}

sub get_forum_moderators {
    my ( $self, $c, $forum_id ) = @_;
    
    my @users = $c->model('DBIC')->resultset('UserRole')->search( {
        role  => ['admin', 'moderator'],
        field => $forum_id,
    } )->all;

    my $roles;
    foreach (@users) {
        my $user = $c->model('DBIC')->resultset('User')->find( {
            user_id => $_->user_id,
        }, {
            columns => ['username', 'nickname'],
            cache => 1,
        } );
        if ($_->role eq 'admin') {
            $roles->{$_->field}->{'admin'} = $user;
        } elsif ($_->role eq 'moderator') {
            push @{$roles->{$_->field}->{'moderator'}}, $user;
        }
    }
    
    return $roles;
}

sub get_forum_admin {
    my ($self, $c, $forum_id) = @_;
    
    # get admin
    my $rs = $c->model('DBIC::UserRole')->find( {
        field => $forum_id,
        role  => 'admin',
    } );
    return unless ($rs);
    my $user = $c->model('DBIC::User')->find( { user_id => $rs->user_id } );
    return $user;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;