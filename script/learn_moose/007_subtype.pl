#!/usr/bin/perl

package TestSubtype;

use Moose;
use Moose::Util::TypeConstraints;

# define a subtype
my $sub_verbose = sub {
    my $msg = shift;
    $msg =~ s/\s+$//;
    print STDERR "$msg\n";
};
subtype 'Verbose'
    => as 'CodeRef'
    => where { 1; };

coerce 'Verbose'
    => from 'Int'
    => via {
        if ($_) {
            return $sub_verbose;
        } else {
            return sub { 0 };
        }
    };

has 'verbose' => ( is => 'rw', isa => 'Verbose', coerce => 1, default => 0 );

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
}

package main;
no Moose;

my $subtype = new TestSubtype;
$subtype->debug('line 1'); # will no print
$subtype->verbose(1);
$subtype->debug('line 2');
$subtype->verbose( sub {
    my $msg = shift;
    $msg =~ s/\s+$//;
    print STDERR "[CUS] $msg\n";
} );
$subtype->debug('line 3');

my $subtype2 = new TestSubtype( verbose => 1 );
$subtype2->debug("line 4");

my $subtype3 = new TestSubtype( verbose => sub {
    my $msg = shift;
    $msg =~ s/\s+$//;
    print STDERR "[CUS2] $msg\n";
} );
$subtype3->debug("line 5");

1;