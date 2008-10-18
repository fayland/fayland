#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use PPI;

my $string = do { local $/; <DATA> };
my $doc = PPI::Document->new(\$string);

my $to;
foreach my $ele ( @{ $doc->find('PPI::Token') } ) {
    #print Dumper(\$ele);

    if ( $ele->isa('PPI::Token::Quote::Double') ) {
        unless ( $ele->interpolations ) {
            my $str = $ele->string;
            my $separator = $ele->{separator};
            if ( $str !~ /\'/) {
                $to .= "'$str'";
            } else {
                if ( $str !~ /\~/ ) {
                    $to .= 'q~' . $str . '~';
                } else {
                    $to .= $ele->content;
                }
            }
            next;
        }
    } elsif ( $ele->isa('PPI::Token::Quote::Interpolate') ) {
        # PPI::Token::Quote::Interpolate no ->interpolations
        my $str = $ele->string;
        if ( $str =~ /^\w+$/ ) {
            $to .= "'$str'";
            next;
        }
    }
    $to .= $ele->content;
}

print $to;

__DATA__
my $a = "a";
my $b = "'b'";
my $c = qq~c~;
my $d = qq~'d'~;
my $e = q{e};
my $f = 'f';
if ( $a eq "a" ) {
    print "ok";
}