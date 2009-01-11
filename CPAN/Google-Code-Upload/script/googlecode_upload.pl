#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use Getopt::Long;
use Pod::Usage;
use Google::Code::Upload qw/upload/;

my %params;

GetOptions(
	\%params,
	"help|?",
	"s|summary=s",
	"n|project=s",
	"u|user=s",
	"p|pass=s",
	"l|labels=s",
);

my $file = pop @ARGV;
defined $file or pod2usage(1);
-e $file or die "$file is not found\n";

my @labels;
if ( $params{labels} ) {
	@labels = split(/\,\s*/, $params{labels} );
}

my ( $status, $reason, $url ) = 
	upload( $file, $params{project}, $params{user}, $params{pass}, $params{summary}, \@labels );

if ( $url ) {
	print "The file was uploaded successfully.\nURL: $url\n";
} else {
	print "An error occurred. Your file was not uploaded.\nGoogle Code upload server said: $reason ($status)\n";
}

1;
__END__

=head1 NAME

googlecode_upload - script uploading files to a Google Code project.

=head1 SYNOPSIS

    googlecode_upload.pl [options] FILE

=head1 OPTIONS

=over 4

=item B<-?>, B<--help>

=item B<s|summary>

Short description of the file

=item B<n|project>

Google Code project name

=item B<u|user>

Your Google Code Subversion username

=item B<p|pass=s>

Your Google Code Subversion password

=item B<l|labels>

An optional list of labels to attach to the file

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
