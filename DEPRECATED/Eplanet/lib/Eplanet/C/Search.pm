package Eplanet::C::Search;

use Data::Dumper;
use Carp;
use base 'Catalyst::Base';

sub search : Global {
	my ( $self, $c ) = @_;
	
	my $type = $c->req->params->{'type'};
	my $key = $c->req->params->{'key'};
	if ($type eq 'title') {
		$type = 'cms_title';
	} elsif ($type eq 'Content') {
		$type = 'cms_text';
	} else {
		croak("$type is not I wanted");
	}
	$c->stash->{lists} = [ Eplanet::M::CDBI::Cms->search_like($type => "%$key%") ];
}

1;
