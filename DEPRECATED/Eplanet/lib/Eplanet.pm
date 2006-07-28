package Eplanet;

use strict;
use lib 'E:\Downloads\CatInABox\extlib';
use lib 'E:\svn\Catalyst\Catalyst\lib'; # the svn directory
use Catalyst qw/-Debug Static::Simple/;
use YAML (); # load the config
use Class::Date qw/:errors date now/; # for new,update in list.tt

our $VERSION = '0.04';

# load the YAML Eplanet.yml config file
Eplanet->config(
	YAML::LoadFile(__PACKAGE__->config->{'home'} . '/Eplanet.yml')
);
Eplanet->setup;

sub begin : Private {
	my ( $self, $c ) = @_;
	# if the last part of the url is build, set the "build" as 1.
	$c->stash->{build} = (pop eq 'build')?'1':'0';
	# date now, for list,add,edit etc.
	$c->stash->{date_now} = now;
	$c->stash( CatalystVersion => $Catalyst::VERSION );
}

sub default : Private {
    my ( $self, $c ) = @_;
    #$c->res->output('Congratulations, NewApp is on Catalyst!');
    $c->res->redirect('list') unless ($c->req->path); # if nothing, redirect to list
}

sub end : Private {
	my ( $self, $c ) = @_;
	my $handled = ($c->res->output || $c->res->redirect);
	# by default, the template name is the same as action
	if (! $c->stash->{template} && -e ($c->config->{root} . '/' . $c->req->action . '.tt')) {
		$c->stash->{template} = $c->req->action . '.tt';
	}

	# if no output or not redirect, handle it by template
	if (! $handled && $c->stash->{template}) {
		$c->forward('Eplanet::V::TT');
	}	
}

1;
