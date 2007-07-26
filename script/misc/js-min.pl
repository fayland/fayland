#!/usr/bin/perl

use strict;
use warnings;
use JavaScript::Minifier qw(minify);
use File::Next;
use Cwd qw/abs_path/;
use File::Basename;
use File::Path;

my $js_dir = shift @ARGV;
-e $js_dir or die "the dir $js_dir is not existence";
$js_dir = abs_path( $js_dir ) ;

my $iter = File::Next::files( $js_dir );

while ( defined ( my $file = $iter->() ) ) {

    next if ($file !~ /\.js$/);
    next if ($file =~ "/min/");
    next if ($file =~ "/xinha/"); # skip xinha

    my $in_file = $file;
    my $out_file = $in_file;
    $out_file =~ s/\/js\//\/js\/min\//is;

    my $out_dir = dirname($out_file);
    unless (-d $out_dir) {
        mkpath( [$out_dir], 0, 0777 );    # mkdir -k
    }

    print "$in_file > $out_file\n";
    minify_js($in_file, $out_file);
}

sub minify_js {
    my ($in_file, $out_file) = @_;

    open(INFILE, $in_file) or die;
    open(OUTFILE, ">$out_file") or die;
    minify(input => *INFILE, outfile => *OUTFILE);
    close(INFILE);
    close(OUTFILE);
}

1;
