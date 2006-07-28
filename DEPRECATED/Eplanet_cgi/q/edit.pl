my $id = $query->param('id');
$id =~ /^[0-9]+$/ or die 'param id is wrong';
my $action = $query->param('act');
if ($action eq 'do') {
	my $file = $query->param('file');
	my $cate_id = $query->param('cate_id');
	my $tilte = $query->param('tilte');
	$tilte = $dbh->quote($tilte);
	my $describe = $query->param('describe');
	$describe = $dbh->quote($describe);
	my $text = $query->param('text');
	# code convert
	while ($text =~/\<code\>(.+?)\<\/code\>/is) {
		my $_temp = $1;
		$_temp =~ s/\</\&lt\;/sg;
		#$_temp =~ s/\>/\&gt\;/sg;
		$text =~ s/\<code\>(.+?)\<\/code\>/\&lt\;code\>$_temp\&lt\;\/code\>/is;
	}
	$text =~ s/\&lt\;(\/)?code\>/\<$1code\>/isg;
		# L<module>
	$text =~ s/L\<([a-z0-9_:]+)\>/\<a href\=\'http:\/\/search\.cpan\.org\/perldoc\?$1\'\>$1\<\/a\>/isg;
		# [[(http|ftp)://]]
	$text =~ s/\[\[((http|https|ftp)\:\/\/\S+?)\]\]/\<a href\=\'$1\'\>$1\<\/a\>/isg;
	$text = $dbh->quote($text);
	my $keywords = $query->param('keywords');
	my $dbhquery = "UPDATE cms SET
		cms_cat_id = '$cate_id',
		cms_title = $tilte,
		cms_describe = $describe,
		cms_text = $text,
		cms_keywords = '$keywords',
		cms_mod_data = NOW()
		WHERE cms_id = $id";
	$dbh->do($dbhquery) or die "$DBI::errstr";
	print "Success. See <a href='Eplanet.cgi'>Eplanet Indexpage</a>, <a href='Eplanet.cgi?q=topic&id=$id&build=1'>Build</a>, <a href='?q=topic&id=$id'>See this</a>";
} else {
	#Get Date
	my $dbhquery = "SELECT * FROM cms WHERE cms_id=$id";
	my $sth = $dbh->prepare($dbhquery);
	$sth->execute() or die "$DBI::errstr";
	my $cat = $sth->fetchrow_hashref();
	$sth->finish;
	$dbhquery = "SELECT * FROM category ORDER BY cat_id";
	$sth = $dbh->prepare($dbhquery);
	$sth->execute();
	my $cats = $sth->fetchall_arrayref({});
	unless ($cat->{'cms_cat_id'}) { die 'no such entry'; }
	$sth->finish;

	# to support the old formatter.
	#$cat->{'cms_text'} =~ s/(span|div|p) class=(\'|\")(highlight|subtitle)(\'|\")\>(.*?)\<\/\1\>(<(br|p)\>)?/h2\>$5\<\/h2\>/isg;
	my $vars  = {
		ID  => $id,
		CATID => $cat->{'cms_cat_id'},
		FILENAME => $cat->{'cms_file'},
		TITLE  => $cat->{'cms_title'},
		DESCRIBE  => $cat->{'cms_describe'},
		TEXT  => $cat->{'cms_text'},
		KEYWORDS  => $cat->{'cms_keyswords'},
		cates => $cats,
	};
	$tt->process('edit.tt', $vars) || die $tt->error( );
}