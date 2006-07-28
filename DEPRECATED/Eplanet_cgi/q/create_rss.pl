use XML::RSS;

my $RSS_file = "$Cfg{'htmldir'}/../recent.rdf";
my $rss = XML::RSS->new(version => '1.0');

print 'update RSS file<br>';
$rss->channel(
	title        => "Fayland's",
	link         => 'http://www.fayland.org/',
	description  => 'What Fayland says',
	language     => 'zh-cn',
	copyright    => '(c)2005, all rights reserved',
	syn => {
		updatePeriod     => 'daily',
		updateFrequency  => '1',
		updateBase       => '2005-01-12T00:00+00:00',
	},
);
my $sth = $dbh->prepare(
    qq{SELECT * FROM cms ORDER BY cms_id DESC LIMIT 0, 20}
);
$sth->execute();
my $cats = $sth->fetchall_arrayref({});
$sth->finish;

foreach my $cat (@$cats) {
	$rss->add_item(
		title       => "$cat->{'cms_title'}",
		link        => "http://www.fayland.org/journal/$cat->{'cms_file'}.html",
		description => "$cat->{'cms_describe'}",
	);
}

$rss->save($RSS_file);