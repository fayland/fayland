package Eplanet::C::Del;

use Data::Dumper;
use strict;
use base 'Catalyst::Base';

sub del : Global {
		my ( $self, $c, $id) = @_;
	
		# id data
		my $del_date = Eplanet::M::CDBI::Cms->retrieve($id);
		$del_date->delete;
	
		$c->res->redirect($c->req->base);
}

1;
