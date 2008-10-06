package MooseX::Attribute::Reload;

use Moose::Role;

    has reload => (
        is        => 'rw',
        isa       => 'Bool',
    );

around '_process_options' => sub {
    my ($_process_options, $self, $name, $options) = (shift, @_);
    
    
	my $builder = $options->{builder};
	my $reload  = $options->{reload};
	
	print STDERR "$builder and $reload\n";

    $_process_options->($self, $name, $options);
};


package Moose::Meta::Attribute::Custom::Trait::Reload;
sub register_implementation { 'MooseX::Attribute::Reload' }


package TestA;

use Moose;
use List::Util qw/shuffle/;

has lists => (
    is => 'rw',
    isa => 'ArrayRef',
    traits => [qw/Reload/],
    reload => 1,
    builder => '_get_lists',
    auto_deref => 1,
);

sub _get_lists {
    my ($self) = @_;
    
    $self->lists( [ 1 .. 9 ] ) unless (scalar $self->lists);

    return [ shuffle( $self->lists ) ];
}

package main;

my $t = new TestA;

print join(',', $t->lists) . "\n";
print join(',', $t->lists) . "\n";