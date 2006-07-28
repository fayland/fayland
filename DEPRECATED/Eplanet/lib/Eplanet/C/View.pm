package Eplanet::C::View;

use Data::Dumper;
use Carp;
use base 'Catalyst::Base';
use List::MoreUtils qw(uniq);

sub view : Global {
	my ( $self, $c, $id ) = @_;
	
	croak("Man, give me the id") unless ($id =~ /^\d+$/);
	
	my $cms = Eplanet::M::CDBI::Cms->retrieve($id);
	$c->stash->{topic} = $cms;
	
	# catagory
	$c->stash->{category} = Eplanet::M::CDBI::Category->retrieve($cms->get('cms_cat_id'));
	
	# prev & next
	my @list = Eplanet::M::CDBI::Cms->retrieve_from_sql("cms_id < $id ORDER BY cms_id DESC LIMIT 1");
	$c->stash->{prev_topic} = $list[0];
	
	@list = Eplanet::M::CDBI::Cms->retrieve_from_sql("cms_id > $id LIMIT 1");
	$c->stash->{next_topic} = $list[0];


	$c->stash->{build_filename} = $cms->get('cms_file') if ($c->stash->{build});
	
	$c->stash->{cms_text} = $cms->get('cms_text');
	my $formatter;
	if ($cms->get('cms_formatter') eq 'textile') {
		use Text::Textile;
		$formatter = Text::Textile->new();
		$formatter->charset('utf-8');
		
		$c->stash->{cms_text} = $formatter->process( $c->stash->{cms_text} );
	} elsif ($cms->get('cms_formatter') eq 'kwiki') {
		use Text::KwikiFormatter;
		$formatter = Text::KwikiFormatter->new();
		
		$c->stash->{cms_text} = $formatter->process( $c->stash->{cms_text} );
	} elsif ($cms->get('cms_formatter') eq 'fayland') {
		use Text::Formatter::Fayland;
		$formatter = Text::Formatter::Fayland->new();
		
		$c->stash->{cms_text} = $formatter->process( $c->stash->{cms_text} );
	} elsif ($cms->get('cms_formatter') eq 'land') {
		use Text::Formatter::Land;
		$formatter = Text::Formatter::Land->new();
		
		$c->stash->{cms_text} = $formatter->process( $c->stash->{cms_text} );
	} else {
		# default
		$c->stash->{cms_text} =~ s/\r//g;
		# for <code>
		while ($c->stash->{cms_text} =~/\<code\>(.+?)\<\/code\>/is) {
			my $_temp = $1;
			$_temp =~ s/\</\&lt\;/sg;
			#$_temp =~ s/\>/\&gt\;/sg;
			$c->stash->{cms_text} =~ s/\<code\>(.+?)\<\/code\>/\&lt\;code\>$_temp\&lt\;\/code\>/is;
		}
		$c->stash->{cms_text} =~ s/\&lt\;(\/)?code\>/\<$1code\>/isg;
	}
	
	# related items
	my $keywords = $cms->get('cms_keywords');
	my @related_items;
	foreach my $keyword (split(/\s+/, $keywords)) {
		next unless ($keyword);
		my @items = Eplanet::M::CDBI::Cms->search_like(cms_keywords => "%$keyword%");
		push @related_items, @items;
		last if (scalar @related_items > 5);
	}
	@related_items = uniq @related_items;
	# "scalar @related_items > 1" means more than one(itself)
	$c->stash->{related_items} = \@related_items if (scalar @related_items > 1);
	
	#$c->res->output(Dumper($c->stash->{next_topic}));
}

1;
