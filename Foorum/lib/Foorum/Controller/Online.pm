package Foorum::Controller::Online;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub default : Private {
    my ($self, $c, undef, $forum_id) = @_;
    
    $c->log->debug("forum_id: $forum_id");
    my $session = $c->model('Online')->get_data($c, $forum_id);
    
    my @results;
    foreach my $p (@$session) {
       my $data = $c->get_session_data($p->id);
       my $refer = $data->{url_referer};
       my $visit_time  = $data->{__created};
       my $active_time = $data->{__updated};
       my $IP          = $data->{__address};
       my $user;
       $user = $c->model('DBIC::User')->find( { user_id => $p->user_id } ) if ($p->user_id);
       push @results, { user => $user, refer => $refer, visit_time => $visit_time, active_time => $active_time, IP => $IP };
    }
    
    $c->stash( {
        results  => \@results,
        template => 'site/online.html',
    } );
    #$c->res->body(Dumper(\@results));
}

1;
