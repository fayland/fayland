package Eplanet::C::ListCat;

use Data::Page;
use YAML;
use strict;
use base 'Catalyst::Base';

sub category : Global {
	my ( $self, $c, $cat_id) = @_;
	
	# category
	$c->stash->{cats} = [ Eplanet::M::CDBI::Category->retrieve_all ];
	
	# the total count of cms
	$c->stash->{lists} = [ Eplanet::M::CDBI::Cms->retrieve_from_sql(qq{
	cms_cat_id=$cat_id ORDER BY cms_id DESC
	}) ];
	
	# this category, damn it.
	#if script in database_category_cms_id = 2, now @cats[1] is.
	$cat_id--;
	$c->stash->{cat} = $c->stash->{cats}->[$cat_id];
	
	# filename
	if ($c->stash->{build}) {
		$c->stash->{build_filename} = $c->stash->{cat}->get('cat_name') ;
	}
	
	# back
	if (-e $c->config->{build_root} . "/journal/" . $c->stash->{cat}->get('cat_name') . '.html') {
		$c->stash->{more} = 1;
	}

	#$c->res->output(Dump($c->stash));
}

1;
