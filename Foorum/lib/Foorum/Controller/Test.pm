package Foorum::Controller::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

sub test : Global {
    my ( $self, $c ) = @_;

    $c->stash( {
        use_Multilingual => 1,
        no_wrapper => 1,
        template => 'test/index.html',
        language => $c->req->param('lang') || 'en',
    } );
}


=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;