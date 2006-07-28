my $id = $query->param('id');
$id =~ /^[0-9]+$/ or die 'param id is wrong';
my $dbhquery = "SELECT MAX(cms_id) FROM cms";
my $sth = $dbh->prepare($dbhquery);
$sth->execute() or die "$DBI::errstr";
my ($max_id) = $sth->fetchrow_array();
$sth->finish;
$max_id++;
$dbhquery = "UPDATE cms SET cms_id = $max_id WHERE cms_id = $id";
$dbh->do($dbhquery) or die "$DBI::errstr";
print "MoVed to ToP success!Back to <a href='Eplanet.cgi'>IndexPage</a>";

1;