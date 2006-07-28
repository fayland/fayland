#!/usr/bin/perl

#use strict;
#use CGI::Carp qw(fatalsToBrowser);
use CGI qw/redirct/;

my $dir = "$ENV{'DOCUMENT_ROOT'}/journal";
unless (-e $dir) { die "no such dir, please set the \$dir<br>$dir non-exist"; }
opendir(DIR, $dir);
my @files = readdir(DIR);
closedir(DIR);

my @wantfiles;
foreach (@files) {
	next unless (/\.html$/); # we only need the html files
	next if (/^index/); # forget the index files
	push(@wantfiles, $_);
}

my $total = scalar @wantfiles; # the num for radom
my $random = int(rand($total));

print CGI::redirect("http://www.fayland.org/journal/$wantfiles[$random]");
