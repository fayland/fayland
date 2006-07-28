use strict;

#all data
my $sth = $dbh->prepare(
	q~SELECT * FROM cms ORDER BY cms_cat_id~
);
$sth->execute() or die "$DBI::errstr";
my $cats = $sth->fetchall_arrayref({});

#category
$sth = $dbh->prepare(
	q{SELECT * FROM category ORDER BY cat_id}
);
$sth->execute() or die "$DBI::errstr";
my $category = $sth->fetchall_arrayref({});

$sth->finish;

my $_build = $query->param('build');

my $vars  = {
	cats => $cats,
	category => $category,
	build => $_build,
};

if ($_build) {
	open(FH, ">$Cfg{'htmldir'}/Archive.html");
	$tt->process('archive.tt', $vars, \*FH) || die $tt->error( );
	close(FH);
	print qq~build Archive success.<a href="$Cfg{'htmldir'}/Archive.html">$Cfg{'htmldir'}/Archive.html</a>~;
} else {
	$tt->process('archive.tt', $vars) || die $tt->error( );
	print qq~<p><span class='op'><a href='Eplanet.cgi?q=build_archive&build=1'>Build this</a></span>~;
}

1;