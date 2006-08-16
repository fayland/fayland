package Foorum::Controller::Online;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub default : Private {
    my ($self, $c, undef, $forum_id) = @_;
    
    $c->log->debug("forum_id: $forum_id");
    my ($results, $pager) = $c->model('Online')->get_data($c, $forum_id);

    $c->stash( {
        results  => $results,
        pager    => $pager,
        template => 'site/online.html',
    } );
    #$c->res->body(Dumper(\@results));
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
