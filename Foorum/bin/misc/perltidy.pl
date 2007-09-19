#!/usr/bin/perl -w

use strict;
use FindBin qw/$Bin $RealBin/;
use Cwd qw/abs_path/;
use lib "$FindBin::Bin/../../lib";
use Perl::Tidy;
use File::Next;

my $path = abs_path("$RealBin/../../lib");

my $files = File::Next::files( $path );

while ( defined ( my $file = $files->() ) ) {
    next if ($file !~ /\.pm$/); # only .pm
    Perl::Tidy::perltidy(
        source            => $file,
        destination       => $file,
        perltidyrc        => '.perltidyrc',
    );
}

exit;

1;