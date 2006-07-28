use strict;
use Data::Page; # for page
my $in_page = $query->param('page');
$in_page = 1 if ($in_page !~ /^[0-9]+$/);
my $_build = $query->param('build');

# fecth the total of records.
my $sth = $dbh->prepare(
	q~SELECT COUNT(*) FROM cms~
);
$sth->execute() or die "$DBI::errstr";
my ($total) = $sth->fetchrow_array();

my $page = Data::Page->new($total, 20, $in_page);
# the page
my $page_content = '<span class="high_digit">' . $page->last_page . '</span> Pages, [ ';
foreach (1 .. $page->last_page) {
	if ($_ == $page->current_page) {
		$page_content .= qq~$_ ~;
	} else {
		if ($_build) {
			$page_content .= qq~<a href='index$_.html'>$_</a> ~;
		} else {
			$page_content .= qq~<a href='?q=show&page=$_'>$_</a> ~;
		}
	}
}
$page_content =~ s/index1\./index\./s;# for the special first page
$page_content .='<a href="Archive.html">ALL</a> ]';

my $off_set = ($in_page - 1) * 20;
# fecth the records
$sth = $dbh->prepare(
    qq{SELECT * FROM cms ORDER BY cms_id DESC LIMIT $off_set, 20}
);
$sth->execute();
my $cats = $sth->fetchall_arrayref({});
$sth->finish;
#category
$sth = $dbh->prepare(
	q{SELECT * FROM category ORDER BY cat_id}
);
$sth->execute();
my $category = $sth->fetchall_arrayref({});
$sth->finish;

#Sec Update & New
my ($sec, $min, $hour, $day, $mon, $year) = localtime();
$mon++;$year += 1900;
#End

my @_list;

foreach my $cat (@$cats) {
	#Sec Update & New,if MofidiedDay + 2 < NOW
	my $_statu;
	my ($_year, $_mon, $_day) = ( $cat->{'cms_cre_data'} =~ /^([0-9]+)\-([0-9]+)\-([0-9]+)/);
	#if New, forget Update
	if ($_mon == $mon && $_day + 4 > $day && $_year == $year) {
		$_statu = qq~ <span class="new">New</span>~;
	} else {
		($_year, $_mon, $_day) = ( $cat->{'cms_mod_data'} =~ /^([0-9]+)\-([0-9]+)\-([0-9]+)/);
		$_statu .= qq~ <span class="update">Update</span>~ if ($_mon == $mon && $_day + 2 > $day && $_year == $year);
	}
	#End
	if ($_build) {
		push @_list, "<li><a href='$cat->{'cms_file'}.html'>$cat->{'cms_title'}</a>$_statu < <span class='digit'>$cat->{'cms_cre_data'}</span> ><br>$cat->{'cms_describe'}";
	} else {
		push @_list, "<li><a href='?q=topic&id=$cat->{'cms_id'}'>$cat->{'cms_title'}</a>$_statu < <span class='digit'>$cat->{'cms_cre_data'}</span> > <span class='op'>(<a href='?q=topic&id=$cat->{'cms_id'}&build=1'>Build</a>)(<a href='?q=edit&id=$cat->{'cms_id'}'>Edit</a>)(<a href='?q=del&id=$cat->{'cms_id'}'>Del</a>)(<a href='?q=top&id=$cat->{'cms_id'}'>ToP</a>)</span><br>$cat->{'cms_describe'}";
	}
}

my $vars = {
	LASTMODDATA => "$year-$mon-$day $hour:$min:$sec",
	LIST => \@_list,
	cats => $category,
	build => $_build,
	total => $total,
	page => $page_content,
};

if ($_build) {
	$in_page = '' if ($in_page == 1);# for the specail first page
	open(FH, ">$Cfg{'htmldir'}/index$in_page.html");
	$tt->process('show.tt', $vars, \*FH) || die $tt->error( );
	close(FH);
	print qq~build success .see <a href="$Cfg{'htmldir'}/index$in_page.html">$Cfg{'htmldir'}/index$in_page.html</a>~;
} else {
	$tt->process('show.tt', $vars) || die $tt->error( );
	print qq~<p><span class='op'><a href="?q=add">Add a new Entry?</a> | <a href="?q=show&build=1&page=$in_page">Build This Page?</a>(<a href='?q=build_allpages&type=page&page=~, $page->last_page, qq~'>ALL</a>) | <a href="?q=buildall">Build All Topic Page?</a> | <a href="?q=build_archive">Archive Page?</a>(<a href='?q=build_archive&build=1'>Build</a>)  | <a href="?q=create_rss">UPdate RSS</a>
	<br>BUild Category: ~;
	foreach my $cat (@$category) {
		print qq~<a href="?q=category&cat_id=$cat->{'cat_id'}">$cat->{'cat_name'}</a> ~;
	}
	print <<HTML;
(<a href='?q=build_allpages&type=cat&cat=
HTML
	print scalar @$category;
	print <<HTML;
'>ALL</a>)
<br>
<form action='Eplanet.cgi' method='post'><input type='hidden' name='q' value='search'>Search: <select name='type'>
<option value='title'>Title</option>
<option value='id'>ID</option>
</select>
<input type='text' name='key' size='30'><input type='submit'></form>
</span></p>
HTML
}

1;