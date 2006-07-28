package Eplanet::C::BuildAll;

use Data::Dumper;
use Carp;
use strict;
use base 'Catalyst::Base';

sub build_indexs : Global {
	my ($self, $c, $type, $id) = @_;

	croak('Only sorry is not enough, wrong type') if ($type ne 'list' && $type ne 'category');
	croak('damn, what u want?') unless ($id =~ /^\d+$/);
	
	my $output;
	
	foreach (1 .. $id) {
#		my $success = get($c->req->{base} . "$type/$_/build");
#		unless ($success) {
#			$output .= "damn, wrong wrong again to get /$type/$_/build\n";
#		} else {
			$output .= "Whooo! $type $_ success<br>";
#		}
		$c->req->action(undef);$c->res->output(undef);
		$c->req->path("$type/$_/build");
		$c->prepare_action();
    	local $NEXT::NEXT{$c,'dispatch'};
    	$c->dispatch();		
	}
	$c->res->output($output);
}

sub build_alltopics : Global {
	my ($self, $c) = @_;
	
	$c->stash->{build} = 1;
	$c->stash->{template} = 'view.tt';
	
	my @cms = Eplanet::M::CDBI::Cms->retrieve_all;
	
	my $i;
	
	foreach (0 .. $#cms) {
		$c->req->action(undef);$c->res->output(undef);
		$c->req->path('view/'. $cms[$_]->{'cms_id'} .'/build');
		$c->prepare_action();
    	local $NEXT::NEXT{$c,'dispatch'};
    	$c->dispatch();	
    	$i++;
	}
	$c->res->output("Total is $i");
	
}

1;
