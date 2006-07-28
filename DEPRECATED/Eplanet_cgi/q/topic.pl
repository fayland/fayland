use strict;

my $id = $query->param('id');
$id =~ /^[0-9]+$/ or die 'param id is wrong';

# got the next and previous topic id
my $sth = $dbh->prepare("SELECT cms_id FROM cms ORDER BY cms_id");
$sth->execute();
my @id;
while (my @_id = $sth->fetchrow_array()) {
	push (@id, @_id);
}
my $all_id = "_" . join("_", @id) . "_";
my ($prev_id, $next_id) = ($all_id =~ /\_?([0-9]+)?\_$id\_(\d+)?\_?/s);

$sth = $dbh->prepare("SELECT * FROM cms WHERE cms_id = ?");
$sth->execute("$id");
my $cat = $sth->fetchrow_hashref();

#got the next/prev topic
my ($prev_topic, $next_topic);
if ($prev_id) {
	$sth->execute("$prev_id");
	$prev_topic = $sth->fetchrow_hashref();
}
if ($next_id) {
	$sth->execute("$next_id");
	$next_topic = $sth->fetchrow_hashref();
}

$sth->finish;

my $_build = $query->param('build');

$cat->{'cms_text'} =~ s/[\a\f\e\0\r]//isg;

my $vars  = {
	TOPIC => $cat,
	PREVT => $prev_topic,
	NEXTT => $next_topic,
	build => $_build,
};

if ($_build) {
	open(FH, ">$Cfg{'htmldir'}/$cat->{'cms_file'}.html");
	$tt->process('topic.tt', $vars, \*FH) || die $tt->error( );
	close(FH);
	print qq~build success.<a href="$Cfg{'htmldir'}/$cat->{'cms_file'}.html">$Cfg{'htmldir'}/$cat->{'cms_file'}.html</a>~;
} else {
	print qq~<span class='op'><a href='Eplanet.cgi'>Indexpage</a> | <a href='Eplanet.cgi?q=topic&id=$id&build=1'>Build</a> | <a href='Eplanet.cgi?q=edit&id=$id'>Edit</a></span><p>~;
	$tt->process('topic.tt', $vars) || die $tt->error( );
}


1;