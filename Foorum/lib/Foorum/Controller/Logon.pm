package Foorum::Controller::Logon;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;

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
	 	    
	 		# login_times++
	 		$c->user->update( {
	 		    login_times   => $c->user->login_times + 1,
	 		    last_login_on => DateTime->now,
	 		    last_login_ip => $c->req->address,
	 		} );
	 		
	 		# redirect
	 		my $referer = $c->session->{url_referer};
	 		$c->log->debug("Refer to: " . $referer);
     		if ($referer) {
     		    $c->res->redirect($c->req->base . $referer);
     		} else {
     		    $c->res->redirect('/board');
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
	
	# log the user out
	$c->logout;
	
	$c->res->redirect('/');
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;