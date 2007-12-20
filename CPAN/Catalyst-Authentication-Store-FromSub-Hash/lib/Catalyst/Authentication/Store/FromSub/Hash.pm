package Catalyst::Authentication::Store::FromSub::Hash;


use warnings;
use strict;
use vars qw/$VERSION/;
$VERSION = '0.04';

use Catalyst::Authentication::User::Hash;
use Scalar::Util qw( blessed );

sub new {
    my ( $class, $config, $app, $realm) = @_;

    bless { config => $config }, $class;
}

sub from_session {
	my ( $self, $c, $id ) = @_;

	return $id if ref $id;

	$self->find_user( { id => $id } );
}

sub find_user {
    my ( $self, $userinfo, $c ) = @_;

    my $id = $userinfo->{'id'};
    
    $id ||= $userinfo->{'username'};
    
    my $model_class = $self->{config}->{model_class};
    my $model = $c->model($model_class);
    
    my $user = $model->auth($c, $userinfo);
    return unless $user;

    if ( ref($user) eq "HASH") {
        $user->{id} ||= $id;
        return bless $user, "Catalyst::Authentication::User::Hash";
    } elsif ( ref($user) && blessed($user) && $user->isa('Catalyst::Authentication::User::Hash')) {
        return $user;
    } else {
        Catalyst::Exception->throw( "The user '$id' must be a hash reference or an " .
                "object of class Catalyst::Authentication::User::Hash");
    }
    return $user;
}

sub user_supports {
    my $self = shift;

    my $model = $self->{config}->{model_class};

    $model->supports(@_);
}

## Backwards compatibility
#
# This is a backwards compatible routine.  get_user is specifically for loading a user by it's unique id
# find_user is capable of doing the same by simply passing { id => $id }  
# no new code should be written using get_user as it is deprecated.
sub get_user {
    my ( $self, $id ) = @_;
    $self->find_user({id => $id});
}

## backwards compatibility
sub setup {
    my $c = shift;

    $c->default_auth_store(
        __PACKAGE__->new( 
            $c->config->{authentication}, $c
        )
    );

	$c->NEXT::setup(@_);
}

1;
__END__

=head1 NAME

Catalyst::Authentication::Store::FromSub::Hash - A storage class for Catalyst Authentication using one Catalyst Model class (hash returned)

=head1 SYNOPSIS

    use Catalyst qw/Authentication/;

    __PACKAGE__->config->{authentication} = 
                    {  
                        default_realm => 'members',
                        realms => {
                            members => {
                                credential => {
                                    class => 'Password',
                                    password_field => 'password',
                                    password_type => 'clear'
                                },
                                store => {
                                    class => 'FromSub::Hash',
                                    model_class => 'UserAuth',
            	                }
                            }
                    	}
                    };

    # Log a user in:
    sub login : Global {
        my ( $self, $c ) = @_;
        
        $c->authenticate({  
                          username => $c->req->params->username,
                          password => $c->req->params->password,
                          }))
    }
    
    package MyApp::Model::UserAuth; # map with model_class in config above
    use base qw/Catalyst::Model/;
    use strict;
    
    sub auth {
        my ($self, $c, $userinfo) = @_;
        
        my $where;
        if (exists $userinfo->{user_id}) {
            $where = { user_id => $userinfo->{user_id} };
        } elsif (exists $userinfo->{username}) {
            $where = { username => $userinfo->{username} };
        } else { return; }
    
        
        # deal with cache
        # if (my $val = $c->cache->get($key) {
        #     return $val;
        # } else {
            my $user = $c->model('TestApp')->resultset('User')->search( $where )->first;
            $user = $user->{_column_data}; # hash
        #     $c->cache->set($key, $user);
        # }

        return $user;
    }

    
=head1 DESCRIPTION

Catalyst::Authentication::Store::FromSub::Hash class provides 
access to authentication information by using a Catalyst Model sub auth.

In sub auth of the Catalyst model, we can use cache there. it would avoid the hit of db every request.

=head1 CONFIGURATION

The FromSub::Hash authentication store is activated by setting the store
config's B<class> element to 'FromSub::Hash'.  See the 
L<Catalyst::Plugin::Authentication> documentation for more details on 
configuring the store.

The FromSub::Hash storage module has several configuration options


    __PACKAGE__->config->{authentication} = 
                    {  
                        default_realm => 'members',
                        realms => {
                            members => {
                                credential => {
                                    # ...
                                },
                                store => {
                                    class => 'FromSub::Hash',
            	                    model_class => 'UserAuth',
            	                }
                	        }
                    	}
                    };

=over 4

=item class

Class is part of the core Catalyst::Authentication::Plugin module, it
contains the class name of the store to be used.

=item user_class

Contains the class name (as passed to $c->model()) of Catalyst.  This config item is B<REQUIRED>.

=back

=head1 USAGE 

The L<Catalyst::Authentication::Store::FromSub::Hash> storage module
is not called directly from application code.  You interface with it 
through the $c->authenticate() call.  

=head1 EXAMPLES

=head2 Adv.

    package MyApp::Model::UserAuth; # map with model_class in config above
    use base qw/Catalyst::Model/;
    use strict;
    
    sub auth {
        my ($self, $c, $userinfo) = @_;
        
        my ($where, $cache_key);
        if (exists $userinfo->{user_id}) {
            $where = { user_id => $userinfo->{user_id} };
            $cache_key = 'global|user|user_id=' . $userinfo->{user_id};
        } elsif (exists $userinfo->{username}) {
            $where = { username => $userinfo->{username} };
            $cache_key = 'global|user|username=' . $userinfo->{username};
        } else { return; }
    
        my $user;
        if (my $val = $c->cache->get($cache_key) {
            $user = $val;
        } else {
            $user = $c->model('TestApp')->resultset('User')->search( $where )->first;
            $user = $user->{_column_data}; # hash to cache
            $c->cache->set($cache_key, $user);
        }
        
        # validate status
        if ( exists $userinfo->{status} and ref $userinfo->{status} eq 'ARRAY') {
            unless (grep { $_ eq $user->{status} } @{$userinfo->{status}}) {
                return;
            }
        }

        return $user;
    }
    
    # for login
    sub login : Global {
        my ( $self, $c ) = @_;
        
        $c->authenticate({  
                          username => $c->req->params->username,
                          password => $c->req->params->password,
                          status => [ 'active', 'registered' ],
                          }))
    }

=head1 TODO

L<Catalyst::Plugin::Authorization::Roles> is not supported or tested yet.

=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>, L<Catalyst::Plugin::Authentication::Internals>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
