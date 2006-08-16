package Foorum::Controller::Ajax;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub new_message : Local {
    my ($self, $c) = @_;
    
    return unless ($c->user_exists);
    
    my $count = $c->model('DBIC::MessageUnread')->count( {
        user_id => $c->user->user_id,
    } );
    
    if ($count) {
        $c->res->body("<span style='color:red'>You have new message ($count)</span>");
    }
    
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
