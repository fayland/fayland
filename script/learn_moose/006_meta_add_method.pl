#!/usr/bin/perl

package TestA;

use Moose;

has 'name' => ( is => 'rw', isa => 'Str', default => 'Fay' );

sub print_up { print STDERR "UP " . uc( (shift)->name ) . "\n"; }
sub print_down { print STDERR "down " . lc( (shift)->name ) . "\n"; }

no Moose;

package main;

use Data::Dumper;

my $t = new TestA;

$t->print_up();
$t->print_down();

my $old_method = $t->meta->get_method('print_up');
$t->meta->add_method('print_up', sub { print STDERR "UPUP " . uc( (shift)->name ) . "\n"; } );
my $super;
$t->meta->add_method('print_down', sub {
    my ($self) = @_;
    print "downdown " . lc($self->name) . "\n";
} );

$t->print_up();
$t->print_down();


$t->meta->add_method('print_up', $old_method);

$t->print_up();
$t->print_down();

1;