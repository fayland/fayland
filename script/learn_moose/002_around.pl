#!/usr/bin/perl

package Test;

use Moose;
use List::Util qw/shuffle/;

has 'shuffled_list' => (
    is => 'rw',
    isa => 'ArrayRef',
);

around 'shuffled_list' => sub {
    my $next = shift;
    
    my $ret = $next->(@_);
    $ret = [ shuffle( @$ret ) ];
    
    return $ret;
};

package main;
no Moose;

my $t = new Test;

$t->shuffled_list([ 1 .. 10 ]);
print join(', ', @{ $t->shuffled_list } ) . "\n";
print join(', ', @{ $t->shuffled_list } ) . "\n";

1;