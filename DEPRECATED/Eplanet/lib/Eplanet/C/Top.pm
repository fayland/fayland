package Eplanet::C::Top;

use Data::Dumper;
use strict;
use Carp;
use base 'Catalyst::Base';

sub top : Global {
	my ( $self, $c, $id) = @_;
	
		# damn it, when i use $cms->move, return
		# "Can't call method "isa" on an undefined value at C:/usr/site/lib/Class/DBI.pm line 731."
		# damn it twice, Class::DBI can update the primary column
		# so turn to the original method prepare&execute
#			my $cms = Eplanet::M::CDBI::Cms->retrieve($id);
	my $new_id = Eplanet::M::CDBI::Cms->maximum_value_of('cms_id');
	$new_id++;

	my $dbh = Eplanet::M::CDBI::Cms->db_Main();
	$dbh->do(qq|
		UPDATE cms SET cms_id = $new_id WHERE cms_id = $id
	|);
		
#			$cms->autoupdate(1);
#			$cms->set('cms_id' => $new_id);
#			croak("sorry, I don't know how to update the primary column - cms_id");
#			$cms->update;

#			$c->res->output(Dumper($dbh));
	$c->res->redirect($c->req->base);
}

1;
