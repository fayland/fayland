my $cat_id = $query->param('cat_id');
$cat_id =~ /^[0-9]+$/ or die 'param cat_id is wrong';

my $dbhquery = "SELECT * FROM cms WHERE cms_cat_id=$cat_id ORDER BY cms_id DESC";
my $sth = $dbh->prepare($dbhquery);
$sth->execute();

my $cat = $sth->fetchall_arrayref({});
$dbhquery = "SELECT cat_name FROM category WHERE cat_id=$cat_id";
$sth = $dbh->prepare($dbhquery);
$sth->execute();
my ($cat_name) = $sth->fetchrow_array();

$sth = $dbh->prepare(
	q{SELECT * FROM category ORDER BY cat_id}
);
$sth->execute();
my $category = $sth->fetchall_arrayref({});
$sth->finish;

my $_build = $query->param('build');

my $vars  = {
	TITLE => $cat_name,
	all => $cat,
	cats => $category,
	build => $_build,
};

if ($_build) {
	open(FH, ">$Cfg{'htmldir'}/$cat_name.html");
	$tt->process('category.tt', $vars, \*FH) || die $tt->error( );
	close(FH);
	print qq~build category success.<a href="$Cfg{'htmldir'}/$cat_name.html">$Cfg{'htmldir'}/$cat_name.html</a>~;
} else {
	$tt->process('category.tt', $vars) || die $tt->error( );
	print qq~<p><span class='op'><a href='Eplanet.cgi?q=category&cat_id=$cat_id&build=1'>Build this</a></span>~;
}


1;