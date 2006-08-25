package Foorum::Controller::Policy;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub fill_user_role : Private {
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
    
    if ($roles->{$field}->{moderator}) {
        $roles->{is_member} = 1;
        $roles->{is_moderator} = 1;
    }
    
    if ($roles->{site}->{admin} || $roles->{$field}->{admin}) {
        $roles->{is_member} = 1;
        $roles->{is_moderator} = 1;
        $roles->{is_admin} = 1;
    }
    
    $c->stash->{roles} = $roles;
}

sub is_admin : Private {
    my ( $self, $c, $field ) = @_;
    
    $field = 'site' unless ($field);
    &fill_user_role( $self, $c, $field ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_admin};
}

sub is_moderator : Private {
    my ( $self, $c, $field ) = @_;

    $field = 'site' unless ($field);
    &fill_user_role( $self, $c, $field ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_moderator};
}

sub is_user : Private {
    my ( $self, $c, $field ) = @_;
    
    $field = 'site' unless ($field);
    &fill_user_role( $self, $c, $field ) unless ($c->stash->{roles});
    
    return $c->stash->{roles}->{is_member};
}

sub get_forum_moderators : Private {
    my ( $self, $c, $forum_id ) = @_;
    
    my @users = $c->model('DBIC')->resultset('UserRole')->search( {
        role  => ['admin', 'moderator'],
        field => $forum_id,
    } )->all;

    my $roles;
    foreach (@users) {
        my $user = $c->model('DBIC')->resultset('User')->single( {
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

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;