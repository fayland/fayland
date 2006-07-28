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
	my $dbhquery = "INSERT INTO cms SET
		cms_file = '$file',
		cms_cat_id = '$cate_id',
		cms_title = $tilte,
		cms_describe = $describe,
		cms_text = $text,
		cms_keywords = '$keywords',
		cms_cre_data = NOW()";
	$dbh->do($dbhquery) or die "$DBI::errstr";
	print "Success. See <a href='Eplanet.cgi'>Eplanet Indexpage</a>.<br>";
	# RSS
	require "q/create_rss.pl";
	# RSS End
} else {
	my $dbhquery = "SELECT * FROM category ORDER BY cat_id";
	my $sth = $dbh->prepare($dbhquery);
	$sth->execute();
	my $cats = $sth->fetchall_arrayref({});
	$sth->finish;
	my $vars = {
		cates => $cats,
	};
	$tt->process('add.tt', $vars) || die $tt->error( );
}