#!/usr/bin/perl

use strict;
use warnings;

use Win32::GuiTest qw(:ALL);

my $window = GetDesktopWindow();
my @children = FindWindowLike($window);
foreach (@children) {
	my $title = GetWindowText($_);
	my $class = GetClassName($_);
	print "title is $title, class is $class\n";
}