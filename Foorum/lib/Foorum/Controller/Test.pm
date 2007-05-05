package Foorum::Controller::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

sub test : Global {
    my ( $self, $c ) = @_;

    my @column_names = $c->model('DBIC')->source('User')->columns;
    
    $c->res->body( Dumper \@column_names );
}


=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;