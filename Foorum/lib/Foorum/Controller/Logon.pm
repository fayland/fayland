package Foorum::Controller::Logon;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub begin : Private {
    my ($self, $c) = @_;

}

sub login : Global {
    my ( $self, $c ) = @_;
    
    $c->stash->{template} = 'user/login.html';
    return unless ($c->req->param('process'));

    if ( my $username = $c->req->param("username") and my $password = $c->req->param("password") ) {
        if ( $c->login( $username, $password ) ) {
            
            # check if he is actived
            if ($c->user->active_code) {
                my $username = $c->user->username;
                $c->logout;
                return $c->res->redirect("/register/activation/$username");
            }
        
            # remember me
            if ($c->req->param('remember_me')) {
                $c->session_time_to_live( 31536000 ); # 1 Year = 24 * 60 * 60 * 365
            }

            # login_times++
            $c->user->update( {
                login_times   => $c->user->login_times + 1,
                last_login_on => \'NOW()',
                last_login_ip => $c->req->address,
            } );
            
            # redirect
            my $referer = $c->req->param('referer');
            if ($referer) {
                $c->res->redirect($referer);
            } else {
                $c->res->redirect('/');
            }
        } else {
            $c->stash->{error} = 'ERROR_AUTH_FAILED';
        }
     } else {
        $c->stash->{error} = 'ERROR_ALL_REQUIRED';
     }
}

sub logout : Global {
    my ( $self, $c ) = @_;
    
    # delete the user_id in session
    $c->delete_session('log out');
    
    # log the user out
    $c->logout;

    $c->res->redirect('/');
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
