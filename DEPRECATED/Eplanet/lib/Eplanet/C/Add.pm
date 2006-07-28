package Eplanet::C::Add;


use Data::Dumper;
use base 'Catalyst::Base';

sub add : Global {
	my ( $self, $c, $submit ) = @_;
	
	unless ($submit eq 'submit') {
		# category
		$c->stash->{cates} = [ Eplanet::M::CDBI::Category->retrieve_all ];

	} else {

		my %hash;
		for my $key ( keys %{ $c->req->params } ) {
			my $value = $c->req->params->{$key};
			if (Eplanet::M::CDBI::Cms->find_column($key)) { $hash{$key} = $value; }
		}
		$hash{'cms_subdir'} ||= 'journal';
		$hash{'cms_cre_data'} = $c->stash->{date_now};
		
		Eplanet::M::CDBI::Cms->create(\%hash);
	
		#$c->forward('rss');
		$c->res->redirect($c->req->{base}.'rss');
		#$c->res->output($hash{'cms_text'});

	}
}

1;
