package Foorum::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Time::HiRes qw( gettimeofday tv_interval );
use URI::Escape;

__PACKAGE__->config->{namespace} = '';

sub begin : Private {
    my ( $self, $c ) = @_;
    
    $c->stash->{start_t0} = [gettimeofday];
}

sub auto : Private {
	my ( $self, $c ) = @_;
	
	# in case (begin : Private) is overrided
	$c->stash->{start_t0} = [gettimeofday] unless ($c->stash->{start_t0});
	
	# set debug for DBIx::Class
    $ENV{DBIX_CLASS_STORAGE_DBI_DEBUG} = 1 if ($c->debug);
	
	# internationalization
#    if ($c->req->headers->{'accept-language'} =~ /zh\-cn/) {
#        $c->stash->{lang} = 'cn';
#    } else {
        $c->stash->{lang} = $c->req->cookie('pref_lang') || $c->config->{default_pref_lang} || 'en';
#    }
    $c->languages( [ $c->stash->{lang} ] );

	my $path = $c->req->path;	
	# for maintain, but admin can login and do something
	if ($c->config->{maintain} and $path !~ /^(admin|login)\//) {
        $c->stash->{template} = 'simple/maintain.html';
        return 0;
	}
    
    return 1;
}

sub default : Private {
    my ( $self, $c ) = @_;

    # 404
    $c->res->status(404);
    $c->detach('/print_error', [ 'ERROR_404' ] );
}

sub index : Private {
    my ( $self, $c ) = @_;
    
    $c->forward('Foorum::Controller::Forum', 'board');
}

sub end : ActionClass('PathLogger') {
    my ( $self, $c ) = @_;

    return if ($c->res->body);

    if ($c->res->location) {
        # for login using!
        if ($c->res->location =~ /^\/login/) {
            my $location = '/login?referer=/' . $c->req->path;
            $location .= '?' . uri_escape($c->req->uri->query) if ($c->req->uri->query);
            $c->res->location($location);
        }
        return 1;
    }

    # you can configure them in foorum.yml to some domain else
    # like http://static.1313s.com/images
    $c->config->{dir}->{js} = $c->req->base . 'js' unless ($c->config->{dir}->{js});
    $c->config->{dir}->{images} = $c->req->base . 'images' unless ($c->config->{dir}->{images});

    if ($c->stash->{template} =~ /^simple\//) {
        $c->stash->{simple_wrapper} = 1;
    } else {
        # get whos view this page?
        unless ($c->stash->{no_online_view}) {
            my $results = $c->model('Online')->whos_view_this_page($c);
            $c->stash->{whos_view_this_page} = $results;
        }
        $c->stash->{elapsed_time} = tv_interval( $c->stash->{start_t0}, [gettimeofday] );
    }
    $c->forward( $c->view('TT') );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;