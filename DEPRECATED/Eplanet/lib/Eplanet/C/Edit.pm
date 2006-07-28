package Eplanet::C::Edit;

use Data::Dumper;
use Carp;
use base 'Catalyst::Base';

sub edit : Global {
	my ( $self, $c, $id, $submit ) = @_;
	
	croak("Man, give me the id") unless ($id =~ /^\d+$/);
	
	unless ($submit eq 'submit') {
		# category
		$c->stash->{cates} = [ Eplanet::M::CDBI::Category->retrieve_all ];

		# id data
		my $topic = Eplanet::M::CDBI::Cms->retrieve($id);
		$c->stash->{topic} = $topic;
		
		# support the <textarea>
		my $content = $topic->get('cms_text');
		$content =~ s/\<\/textarea\>/\<lt\;\/textarea\>/isg;
		$c->stash->{'cms_text'} = $content;

	} else {
		my $cms = Eplanet::M::CDBI::Cms->retrieve($id);
		
		my %hash;
		for my $key ( keys %{ $c->req->params } ) {
			my $value = $c->req->params->{$key};
			if (Eplanet::M::CDBI::Cms->find_column($key)) { $hash{$key} = $value; }
		}
		$hash{'cms_mod_data'} = $c->stash->{date_now};

		$cms->set(%hash);
		$cms->update;
		
		$c->res->redirect($c->req->base . "view/$id");
	}
}

1;