package TestApp::Controller::Root;
use strict;
use warnings;

__PACKAGE__->config(namespace => q{});

use base 'Catalyst::Controller';

sub main :Path { }

sub nothtml :Local {
  my ($self, $c) = @_;
  $c->res->content_type('application/json');
}

sub end : ActionClass('Fixup::XHTML') {
	my ( $self, $c ) = @_;
	
	$c->forward('TestApp::View::TT');
}

1;
