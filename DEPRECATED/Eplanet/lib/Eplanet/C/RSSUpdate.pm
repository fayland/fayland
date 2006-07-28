package Eplanet::C::RSSUpdate;

use strict;
use Data::Dumper;
use XML::RSS;
use XML::Atom::SimpleFeed;
use base 'Catalyst::Base';

sub rss : Global {
	my ( $self, $c ) = @_;
	
	# normal settings
	my $RSS_file = $c->config->{build_root} . "/recent.rdf";
	my $Atom_file = $c->config->{build_root} . "/atom.xml";
	
	my $site_prefix = 'http://www.fayland.org/doodle';
	my $title = 'Fayland\'s Perl stuff';
	my $link = 'http://www.fayland.org/';
	my $description = 'What Fayland says';
	
	my $rss = XML::RSS->new(version => '1.0');
	my $atom = XML::Atom::SimpleFeed->new(
		title    => $title,
		link     => $link,
		tagline  => $description,
		author => { name => 'Fayland Lam' },
	)
	or die;

	$rss->channel(
		title        => $title,
		link         => $link,
		description  => $description,
		language     => 'zh-cn',
		copyright    => '(c)2005, all rights reserved',
		syn => {
			updatePeriod     => 'daily',
			updateFrequency  => '1',
			updateBase       => '2005-01-12T00:00+00:00',
		},
	);
	
	my @cats = Eplanet::M::CDBI::Cms->retrieve_from_sql(qq{
		1=1 ORDER BY cms_id DESC LIMIT 0, 15
	});

	foreach my $cat (@cats) {
		my $_title = $cat->get('cms_title');
		my $_link = "$site_prefix/$cat->{'cms_file'}.html";
		my $_description = $cat->{'cms_describe'};
		my $_create_data = $cat->{'cms_cre_data'};
		# convert to the standard w3cdtf
		$_create_data = date2w3cdtf($_create_data);
		# got the modified date
		my $_modified_data = $cat->{'cms_mod_data'};
		# if not exists, use create date instead
		if ($_modified_data) {
			$_modified_data = date2w3cdtf($_modified_data);
		} else {
			$_modified_data = $_create_data;
		}
		
		$atom->add_entry(
			title    => $_title,
			link     => $_link,
			author   => { name => "Fayland Lam" },
			issued   => $_create_data,
			created  => $_create_data,
			modified => $_modified_data,
			summary  => $_description,
		)
		or die;
		
		$rss->add_item(
			title       => $_title,
			link        => $_link,
			description => $_description,
			dc => {
				creator  => 'Fayland Lam',
				date     => $_create_data,
			},
		);
	}

	$rss->save($RSS_file);
	$atom->save_file($Atom_file);

	$c->res->body('ok'); #redirect($c->req->{base});	
}

# for rss&atom
sub date2w3cdtf {
	my $date = shift;
	# the original date foramt like 2005-03-29 23:02:14 & it's a localtime
	# so we convert localtime to $time and got the gmtime

	my ($year, $mon, $mday, $hour, $min, $sec) = ($date =~ /^(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)$/);
	$mon--;
	use Time::Local;
	my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
	( $sec, $min, $hour, $mday, $mon, $year) = gmtime($time);
	$year += 1900; $mon++;

	# at last we return the w3c dtf
	my $timestring = sprintf( "%4d-%02d-%02dT%02d:%02d:%02dZ",
        $year, $mon, $mday, $hour, $min, $sec );

	return $timestring;
}

1;
