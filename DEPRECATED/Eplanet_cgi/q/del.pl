my $id = $query->param('id');
$id =~ /^[0-9]+$/ or die 'param id is wrong';
my $confirm = $query->param('confirm');
if ($confirm) {
	my $dbhquery = "DELETE FROM cms WHERE cms_id=$id";
	$dbh->do($dbhquery) or die "$DBI::errstr";
	print "Del success!Back to <a href='Eplanet.cgi'>IndexPage</a>";
} else {
	print qq~
	Are u sure to del the Entry$id ? <a href="Eplanet.cgi?q=del&id=$id&confirm=1">YES</a>
	~;
}

1;