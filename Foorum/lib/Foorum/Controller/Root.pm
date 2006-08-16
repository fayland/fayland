package Foorum::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Time::HiRes qw( gettimeofday tv_interval );

__PACKAGE__->config->{namespace} = '';

# for elapsed_time
my $t0;

sub auto : Private {
	my ( $self, $c ) = @_;
	
	# in case (begin : Private) is overrided
	$t0 = [gettimeofday] unless ($t0);
	
	# for maintain
	if ($c->config->{maintain} and
	    $c->req->path ne 'login') {
	        $c->stash->{template} = 'simple/maintain.html';
	        $c->detach('end');
	        return 0;
	}
	
	# for login using
	my $url_referer = $c->req->path;
    if ($url_referer !~ /ajax\//
    and $url_referer ne 'register'
    and $url_referer ne 'logout'
    and $url_referer ne 'login') {
        $c->session->{url_referer} = $url_referer;
    }
    
    return 1;
}

sub begin : Private {
    my ( $self, $c ) = @_;
    
    $t0 = [gettimeofday];
}

sub default : Private {
    my ( $self, $c ) = @_;

    $c->forward('Foorum::Controller::Forum', 'default');
}

sub end : Private {
    my ( $self, $c ) = @_;
	
	return if ($c->res->body || $c->res->redirect);

    $c->stash->{elapsed_time} = tv_interval( $t0, [gettimeofday] );
    
    # get whos view this page?
    my $results = $c->model('Online')->whos_view_this_page($c);
    #use Data::Dumper;
    #$c->log->debug(Dumper($results));
    $c->stash->{whos_view_this_page} = $results;
    
    # template international
    my $lang = $c->config->{lang} || 'en';
    $c->stash->{additional_template_paths} = [ $c->path_to('templates', $lang) ];

    # Forward to View unless response body is already defined
    if ($c->stash->{template} =~ /^simple\//) {
        $c->forward( $c->view('SimpleTT') );
    } else {
        $c->forward( $c->view('TT') );
    }
}







=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;