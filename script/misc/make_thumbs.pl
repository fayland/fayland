#!/usr/bin/perl
use strict;
use Data::Dumper;
use Image::Magick;

my $dir = $ARGV[0] || 'E:/Downloads/aa';
my $want_width = $ARGV[1] || 600;

-d $dir or die "usage: $0 \$dir \$witdh";
unless (-d "$dir/$want_width") { mkdir "$dir/$want_width", 0777; }

opendir(DIR, $dir);
my @files = readdir(DIR);
closedir(DIR);

foreach my $file (@files) {
    next if ($file !~ /\.jpg/is); # if not jpg file
    $file =~ m/(.*)\.(.*)/;
    my $thumbsfile = "$dir/$want_width/$1.jpg";
    my $image = Image::Magick->new;
    my $x = $image->Read("$dir/$file");
    $image->Set(magick => 'JPEG');
    my ($width, $height) = $image->Get('width', 'height');
    print "$file has $width x $height\n";
    next if ($width < $want_width);
    my $want_height = ($height * $want_width) / $width;
    $image->Resize( width => $want_width, height => $want_height);
    $image->Write("jpeg:$thumbsfile");
    print "convert $file to $want_width x $want_height\n";
}