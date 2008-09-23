#!/usr/bin/perl

package TestA;

use Moose;

has 'name' => ( is => 'rw', isa => 'Str', default => 'Fay' );

sub print_1 { print STDERR "1 " . uc( (shift)->name ) . "\n"; }
sub print_2 { print STDERR "2 " . lc( (shift)->name ) . "\n"; }
sub print_3 { print STDERR "3 " . (shift)->name . "\n" }
sub print_4 { print STDERR "4 " . (shift)->name  }

no Moose;

package main;

use Data::Dumper;

my $t = new TestA;

$t->print_1();
$t->print_2();
$t->print_3();
$t->print_4();

my $old_1_method = $t->meta->get_method('print_1');
$t->meta->add_method('print_1', sub { print STDERR "Re1 - 1 " . uc( (shift)->name ) . "\n"; } );
my $super;
my $old_2_method = $t->meta->get_method('print_2');
$t->meta->remove_method('print_2');
$t->meta->add_method('print_2', sub {
    my ($self) = @_;
    print STDERR "Re2 - ";
    $old_2_method->($self);
} );
$t->meta->add_before_method_modifier('print_3', sub {
    print STDERR "Re3 - ";
} );
$t->meta->add_around_method_modifier('print_4', sub {
    my $next = shift;
    print STDERR "Before - ";
    $next->(@_);
    print STDERR " - After\n";
} );

$t->print_1();
$t->print_2();
$t->print_3();
$t->print_4();

$t->meta->add_method('print_1', $old_1_method);

$t->print_1();
$t->print_2();
$t->print_3();

1;