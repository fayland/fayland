my $dbhquery = "SELECT * FROM cms ORDER BY cms_id";
my $sth = $dbh->prepare($dbhquery);
$sth->execute();
my $cats = $sth->fetchall_arrayref({});
$sth->finish;

my $i = 0;
foreach my $cat (@$cats) {
	my $tt = Template->new({
		INCLUDE_PATH => [
			"$Cfg{'dir'}/tt",
		],
		POST_CHOMP => 1,
		PRE_PROCESS => 'header.tt', 
	});
	my $prev_topic = @$cats->[$i-1] if ($i > 0);
	my $next_topic = @$cats->[$i+1];
	$cat->{'cms_text'} =~ s/[\a\f\e\0\r]//isg;
	my $vars  = {
		TOPIC  => $cat,
		PREVT => $prev_topic,
		NEXTT => $next_topic,
		build => "1",		
	};
	open(FH, ">$Cfg{'htmldir'}/$cat->{'cms_file'}.html");
	$tt->process('topic.tt', $vars, \*FH) || die $tt->error( );
	close(FH);
	print qq~build success. see <a href="$Cfg{'htmldir'}/$cat->{'cms_file'}.html">$Cfg{'htmldir'}/$cat->{'cms_file'}.html</a><br>~;
	$i++;
}

1;