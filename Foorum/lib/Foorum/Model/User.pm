package Foorum::Model::User;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;
use Object::Signature   ();
use Scalar::Util        ();
use Object::Destroyer;

# Usage:
# $c->model('User')->get($c, { user_id => ? } );
# $c->model('User')->get($c, { username => ? } );
# $c->model('User')->get($c, { email => ? } );
sub get {
    my ( $self, $c, $cond ) = @_;
    
    my $cache_key = 'user|' . Object::Signature::signature($cond);
    
    if ($c->stash->{"__user_caches|$cache_key"}) { # avoid memcache get
        $c->log->debug('get user from stash');
        return $c->stash->{"__user_caches|$cache_key"};
    }
    
    my $cache_val = $c->cache->get($cache_key);
    
    if ($cache_val) {
        $c->stash->{"__user_caches|$cache_key"} = $cache_val;
        $c->log->debug('get user from cache: ' . Dumper(\$cond));
        return $cache_val;
    }
    
    # if not cached yet
    # get all to cache: user, user_details, role
    {
        my $user = $c->model('DBIC')->resultset('User')->find( $cond );

        # always set cache
        my $sentry = Object::Destroyer->new( sub {
            $c->log->debug('set user to cache: ' . Dumper(\$cond));
            $c->cache->set($cache_key, $cache_val, 7200); # two hours
            $c->stash->{"__user_caches|$cache_key"} = $cache_val;
            return $cache_val;
        } );

        return unless ($user);
        
        # user_details
        my $user_details = $c->model('DBIC')->resultset('UserDetails')->find( { user_id => $user->user_id } );
        $user_details = $user_details->{_column_data} if ($user_details);
        
        # user role
        my @roles = $c->model('DBIC')->resultset('UserRole')->search( {
            user_id => $user->user_id,
        } )->all;
        my $roles;
        foreach (@roles) {
            $roles->{ $_->field }->{ $_->role } = 1;
        }
        
        # user profile photo
        my $profile_photo;
        if ($user->primary_photo_id) {
            $profile_photo = $c->model('Upload')->get($c, $user->primary_photo_id);
        }
        
        $cache_val = $user->{_column_data};
        $cache_val->{details} = $user_details;
        $cache_val->{roles} = $roles;
        $cache_val->{profile_photo} = $profile_photo;
        return $cache_val;
    }
}

sub delete_cache_by_user {
    my ($self, $c, $user) = @_;
    
    return unless ($user);

    if ( Scalar::Util::blessed($user)
        and $user->isa('Catalyst::Plugin::Authentication::User') ){
        $user = $user->obj;
    }
    
    my @ckeys;
    push @ckeys, 'user|' . Object::Signature::signature( { user_id => $user->{user_id} } );
    push @ckeys, 'user|' . Object::Signature::signature( { username => $user->{username} } );
    push @ckeys, 'user|' . Object::Signature::signature( { email => $user->{email} } );
    
    foreach my $ckey (@ckeys) {
        $c->cache->delete($ckey);
        $c->stash->{"__user_caches|$ckey"} = undef;
    }

    return 1;
}

sub delete_cache_by_user_cond {
    my ($self, $c, $cond) = @_;
    
    my $user = $self->get($c, $cond);
    $self->delete_cache_by_user($c, $user);
}

# call this update will delete cache.
sub update {
    my ($self, $c, $user, $update) = @_;
    
    if ( Scalar::Util::blessed($user)
        and $user->isa('Catalyst::Plugin::Authentication::User') ){
        $user = $user->obj;
    }
    
    $self->delete_cache_by_user($c, $user);
    $c->model('DBIC')->resultset('User')->search( {
        user_id => $user->{user_id},
    } )->update($update);
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
