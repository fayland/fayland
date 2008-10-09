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
    
    my ($to_width, $to_height) = (0, 0);
    if ( $width > $height ) {
        next if ($width < $want_width);
        $to_width  = $want_width;
        $to_height = ($height * $to_width) / $width;
    } else {
        next if ($height < $want_width);
        $to_height = $want_width;
        $to_width  = ($width * $to_height) / $height;
    }
    $image->Resize( width => $to_width, height => $to_height);
    $image->Write("jpeg:$thumbsfile");
    print "convert $file to $to_width x $to_height\n";
}