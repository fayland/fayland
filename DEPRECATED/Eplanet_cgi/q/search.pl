my $key = $query->param('key');
my $type = $query->param('type');
my $_where;
if ($type eq 'id') {
	$key =~ s/[^0-9]*//g;
	$_where = "cms_id=$key";
} else {
	$key = $dbh->quote($key);
	$key =~ s/\'(.*)\'/$1/;
	$_where = qq~cms_title LIKE "%$key%"~;
}
my $dbhquery = "SELECT * FROM cms where $_where";
my $sth = $dbh->prepare($dbhquery);
$sth->execute() or die "$DBI::errstr";
my $cats = $sth->fetchall_arrayref({});
$sth->finish;

print scalar(@$cats), " result, <a href='Eplanet.cgi'>Eplanet Indexpage</a><p>";

foreach my $cat (@$cats) {
		print "<li><a href='Eplanet.cgi?q=topic&id=$cat->{'cms_id'}'>$cat->{'cms_title'}</a>$_statu [ <i><span class='digit'>$cat->{'cms_cre_data'}</span></i> ] <span class='op'>(<a href='Eplanet.cgi?q=topic&id=$cat->{'cms_id'}&build=1'>Build</a>)(<a href='Eplanet.cgi?q=edit&id=$cat->{'cms_id'}'>Edit</a>)(<a href='Eplanet.cgi?q=del&id=$cat->{'cms_id'}'>Del</a>)(<a href='Eplanet.cgi?q=top&id=$cat->{'cms_id'}'>ToP</a>)</span><br>$cat->{'cms_describe'}";
}

1;