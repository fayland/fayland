package Foorum::Controller::Online;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub default : Private {
    my ($self, $c, undef, $forum_code) = @_;

    $c->cache_page( '300' );

    my ($results, $pager) = $c->model('Online')->get_data($c, $forum_code);

    $c->stash( {
        results  => $results,
        pager    => $pager,
        template => 'site/online.html',
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
