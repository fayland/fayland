package Catalyst::Authentication::Store::Sub;

use strict;
use warnings;

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
    
    my $user = $model->get($c, $userinfo);
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

    my $model_class = $self->{config}->{model_class};
    my $model = $c->model($model_class);

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

__PACKAGE__;

__END__

=pod

=head1 NAME

Catalyst::Authentication::Store::Minimal - Minimal authentication store

=head1 SYNOPSIS

    # you probably just want Store::Minimal under most cases,
    # but if you insist you can instantiate your own store:

    use Catalyst::Authentication::Store::Minimal;

    use Catalyst qw/
        Authentication
    /;

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
                                    class => 'Minimal',
                	                users = {
                	                    bob => {
                	                        password => "s00p3r",                	                    
                	                        editor => 'yes',
                	                        roles => [qw/edit delete/],
                	                    },
                	                    william => {
                	                        password => "s3cr3t",
                	                        roles => [qw/comment/],
                	                    }
                	                }	                
                	            }
                	        }
                    	}
                    };

    
=head1 DESCRIPTION

This authentication store lets you create a very quick and dirty user
database in your application's config hash.

You will need to include the Authentication plugin, and at least one Credential
plugin to use this Store. Credential::Password is reccommended.

It's purpose is mainly for testing, and it should probably be replaced by a
more "serious" store for production.

The hash in the config, as well as the user objects/hashes are freely mutable
at runtime.

=head1 CONFIGURATION

=over 4

=item class 

The classname used for the store. This is part of
L<Catalyst::Plugin::Authentication> and is the method by which
Catalyst::Authentication::Store::Minimal is loaded as the
user store. For this module to be used, this must be set to
'Minimal'.

=item users

This is a simple hash of users, the keys are the usenames, and the values are
hashrefs containing a password key/value pair, and optionally, a roles/list 
of role-names pair. If using roles, you will also need to add the 
Authorization::Roles plugin.

See the SYNOPSIS for an example.

=back

=head1 METHODS

There are no publicly exported routines in the Minimal store (or indeed in
most authentication stores)  However, below is a description of the routines 
required by L<Catalyst::Plugin::Authentication> for all authentication stores.

=head2 new( $config, $app, $realm )

Constructs a new store object, which uses the user element of the supplied config 
hash ref as it's backing structure.

=head2 find_user( $authinfo, $c ) 

Keys the hash by the 'id' or 'username' element in the authinfo hash and returns the user.

... documentation fairy stopped here. ...

If the return value is unblessed it will be blessed as
L<Catalyst::Authentication::User::Hash>.

=head2 from_session( $id )

Delegates to C<get_user>.

=head2 user_supports( )

Chooses a random user from the hash and delegates to it.

=head2 get_user( )

=head2 setup( )

=cut


