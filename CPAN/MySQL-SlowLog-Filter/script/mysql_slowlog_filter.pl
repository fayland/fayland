#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

use MySQL::SlowLog::Filter qw/run/;
use Getopt::Long;
use Pod::Usage;

my %params;

GetOptions(
	\%params,
	"help|?",
	"date=s",
	"min_query_time=i",
	
) or pod2usage(2);

pod2usage(1) if $params{help};

my $file = pop @AGRV;
-e $file or die "$file is not found\n";



1;
__END__

=head1 NAME

mysql_showlog_filter - filter your mysql slow.log

=head1 SYNOPSIS

    mysql_showlog_filter [options] FILE

=head1 OPTIONS

=over 4

=item B<?>, B<--help>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
