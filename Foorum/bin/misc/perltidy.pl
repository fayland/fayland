#!/usr/bin/perl -w

use strict;
use FindBin qw/$Bin $RealBin/;
use Cwd qw/abs_path/;
use lib "$FindBin::Bin/../../lib";
use Perl::Tidy;
use File::Next;
use File::Copy;

my $path = abs_path("$RealBin/../../lib");

my $files = File::Next::files( $path );

while ( defined ( my $file = $files->() ) ) {
    next if ($file !~ /\.p[ml]$/); # only .pm .pl
    next if ($file =~ /perltidy/); # skip this file
    next if ($file =~ /\/Schema\//); # skip Schema dir
    next if ($file =~ /Schema\.pm$/); # skip Schema.pm
    my $tidyfile = $file . '.tdy';
    Perl::Tidy::perltidy(
        source            => $file,
        destination       => $tidyfile,
        perltidyrc        => '.perltidyrc',
    );
    move($tidyfile, $file);
}

exit;

1;