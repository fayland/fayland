#!/usr/bin/perl

package TestAugment;

use Moose;

has 'msg' => ( is => 'rw', isa => 'Str', default => 'msg la' );

sub print_msg {
    my $self = shift;
    
    my $text = 'arg1';
    $self->pre_print(\$text);
    print STDERR "msg is " . $self->msg . " with $text\n";
    $self->post_print;
}

sub pre_print   { inner() }
sub post_print  { inner() }

package Test2;

use Moose;
extends 'TestAugment';

augment pre_print => sub {
    my ($self, $text_ref) = @_;
    
    $$text_ref =~ s/\D/0/isg;
    print STDERR "pre msg is " . $self->msg . " with $$text_ref\n";
};
augment post_print => sub {
    my $self = shift;
    print STDERR "post msg is " . $self->msg . "\n";
};

package main;
no Moose;

my $t = new Test2;
$t->print_msg;

# try at runtime
my $t2 = new TestAugment;

$t2->meta->add_method('pre_print', sub {
    my ($self, $args1) = @_;
    print STDERR "2 pre msg is " . $self->msg . " with $$args1\n";
} );
$t2->meta->add_method('post_print', sub {
    my $self = shift;
    print STDERR "2 post msg is " . $self->msg . "\n";
} );

$t2->print_msg;

1;