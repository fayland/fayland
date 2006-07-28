use LWP::Simple;

my $type = $query->param('type');

my ($_url, $page);
if ($type eq 'page') {
	$page = $query->param('page');
	$_url = 'q=show&build=1&page=';
} elsif ($type eq 'cat') {
	$page = $query->param('cat');
	$_url = 'q=category&build=1&cat_id=';
}

die 'wrong id' if ($page !~ /^[0-9]+$/);

foreach (1 .. $page) {
	my $content = get("$Cfg{'url'}/Eplanet.cgi?$_url$_");
	unless (defined $content) {
		warn "Couldn't get $_<br>";
	} else {
		print "Updata $_ success!<br>";
	}
}

print "All is Done! Back to <span class='op'><a href='Eplanet.cgi'>Indexpage</a>";