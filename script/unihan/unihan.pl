#!/usr/bin/perl

use strict;

open(FH, 'unihan.txt') or die $!;
open(MANDARIN, '>Mandarin.dat') or die $!;
open(CANTONESE, '>Cantonese.dat') or die $!;
open(STROKE, '>Stroke.dat') or die $!;
my ($m, $c, $s);
while (<FH>) {
    next if (/\^#/);
    if (/^U\+(\w+)\s+(kCantonese|kMandarin|kTotalStrokes)\s+(.+)$/) {
        if ($2 eq 'kCantonese') {
            print CANTONESE "$1\t$3\n";
            $c++;
        } elsif($2 eq 'kMandarin') {
            my $code = $1;
            my $mandarin = $3;
            $mandarin =~ s/Ü/V/isg;
            print MANDARIN "$code\t$mandarin\n";
            $m++;
        } elsif($2 eq 'kTotalStrokes') {
            print STROKE "$1\t$3\n";
             $s++;
        }
    }
}
close(FH);
close(MANDARIN);
close(CANTONESE);
close(STROKE);
print "mandarin has $m, cantonese has $c, stroke has $s";