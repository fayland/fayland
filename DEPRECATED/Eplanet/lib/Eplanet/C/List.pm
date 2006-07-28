package Eplanet::C::List;

use Data::Page;
use YAML;
use strict;
use base 'Catalyst::Base';

sub list : Global {
	my ( $self, $c, $in_page) = @_;

	# the total count of cms
	$c->stash->{total} = Eplanet::M::CDBI::Cms->count_all;

	# page
	$in_page = (defined $in_page && $in_page =~ /^\d+$/)?$in_page:'1';
	$c->stash->{inpage} = $in_page;

	my $page = Data::Page->new($c->stash->{total}, 20, $in_page);
	
	# the last page, we need it as param for build_indexs
	$c->stash->{lastpage} = $page->last_page;
	
	# page_output
	$c->stash->{page_list} = '<span class="high_digit">' . ($c->stash->{lastpage} + 11) . '</span> Pages, [ ';
	foreach (1 .. $page->last_page) {
		if ($_ == $in_page) {
			$c->stash->{page_list} .= qq~$_ ~;
		} else {
			if ($c->stash->{build} == 1) {
				$c->stash->{page_list} .= qq~<a href='index$_.html'>$_</a> ~;
			} else {
				$c->stash->{page_list} .= qq~<a href='~. $c->req->base. qq~list/$_'>$_</a> ~;
			}
		}
	}
	$c->stash->{page_list} =~ s/index1\./index\./s;# for the special first page
	$c->stash->{page_list} .=q~], Older [ <a href='../journal/index.html'>1</a> <a href='../journal/index2.html'>2</a> <a href='../journal/index3.html'>3</a> <a href='../journal/index4.html'>4</a> <a href='../journal/index5.html'>5</a> <a href='../journal/index6.html'>6</a> <a href='../journal/index7.html'>7</a> <a href='../journal/index8.html'>8</a> <a href='../journal/index9.html'>9</a> <a href='../journal/index10.html'>10</a> <a href='../journal/index11.html'>11</a> ]~;
	
	# filename
	if ($c->stash->{build}) {
		$c->stash->{build_filename} = "index" . $in_page;
		$c->stash->{build_filename} =~ s/^index1$/index/;# for the special first page
	}

	# category
	$c->stash->{cats} = [ Eplanet::M::CDBI::Category->retrieve_all ];
	$c->stash->{lastcat} = $c->stash->{cats}->[-1]->get('cat_id');

	# list data
	my $off_set = ($in_page - 1) * 20;
	$c->stash->{lists} = [ Eplanet::M::CDBI::Cms->retrieve_from_sql(qq{
		1=1 ORDER BY cms_id DESC LIMIT $off_set, 20
	}) ];
	#$c->res->output(Dump($c->stash));
}

1;
