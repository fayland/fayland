package Foorum::Controller::Ajax::Poll;

use strict;
use warnings;
use base 'Catalyst::Controller';
use YAML::Syck;
use Data::Dumper;

sub vote : Local {
    my ($self, $c) = @_;
    
    my $poll_id   = $c->req->param('poll_id');
    my @option_id = $c->req->param('option_id');
    
    # check the 'multi', 'duration' and 'anonymous'
    my $poll = $c->model('DBIC::Poll')->find( {
        poll_id => $poll_id,
    }, {
        columns => ['multi', 'duration', 'anonymous'],
    } );
    
    return $c->res->body('NO SUCH POLL') unless ($poll);
    #return $c->res->body('ANONYMOUS NOT ALLOWED') if (not $poll->anonymous and $c->user_exists);
    return $c->res->body('VOTE EXPIRE') if (time() > $poll->duration));
    
}

# override Root.pm
sub end : Private {
    my ($self, $c) = @_;
    

}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
