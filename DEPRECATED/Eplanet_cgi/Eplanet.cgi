#!/usr/bin/perl
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:standard/;
use DBI;
use Template;
use Template::Constants qw( :chomp );
use vars qw/$query $dbh $tt %Cfg/;

# cgi
$query = new CGI;
print $query->header(-type=>'text/html',-charset=>'utf-8');

# dbi
$dbh = DBI->connect("DBI:mysql:fayland:localhost", 
		'root', undef, { RaiseError => 1, PrintError => 1 }) or die "cann't connect";

# config
$Cfg{'dir'} = 'E:/Fayland/cgi-bin/cms';
$Cfg{'htmldir'} = 'E:/fayland_org/journal';
$Cfg{'url'} = 'http://localhost/cgi-bin/cms';

#template
$tt = Template->new({
	INCLUDE_PATH => [
		"$Cfg{'dir'}/tt",
	],
	POST_CHOMP => 1,
	PRE_PROCESS => 'header.tt', 
});

my $q = $query->param('q');
$q and $q =~ s/[^0-9a-zA-Z_]+//g;
$q = 'show' unless ($q);
if (-e "$Cfg{'dir'}/q/$q.pl") {
	require "$Cfg{'dir'}/q/$q.pl";
} else {
	die "$q.pl not exist!";
}