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
	
	# internationalization
#    if ($c->req->headers->{'accept-language'} =~ /zh\-cn/) {
#        $c->stash->{lang} = 'cn';
#    } else {
        $c->stash->{lang} = 'en';
#    }

	my $url_referer = $c->req->path;	
	# for maintain, but admin can login and do something
	if ($c->config->{maintain} and
	    ($url_referer ne 'login' and $url_referer !~ /^admin\//)) {
	        $c->stash->{template} = 'simple/maintain.html';
	        $c->detach('end');
	        return 0;
	}
	
	# for login using
    if ($c->stash->{no_url_referer} or 
       ($url_referer !~ /^ajax\//
    and $url_referer ne 'register'
    and $url_referer ne 'logout'
    and $url_referer ne 'login')
    ) {
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
    
    die 'I want to die' if ($c->debug and $c->req->param('die')); # for debug using.
	
	return if ($c->res->body || $c->res->redirect);

    # template international
    $c->stash->{additional_template_paths} = [ $c->path_to('templates', $c->stash->{lang}) ];

    # Forward to View unless response body is already defined
    if ($c->stash->{template} =~ /^simple\//) {
        $c->stash->{simple_wrapper} = 1;
    } else {
        
        $c->stash->{elapsed_time} = tv_interval( $t0, [gettimeofday] );
        
        # get whos view this page?
        unless ($c->stash->{no_online_view}) {
            my $results = $c->model('Online')->whos_view_this_page($c);
            $c->stash->{whos_view_this_page} = $results;
        }
    }
    $c->forward( $c->view('TT') );
}







=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;