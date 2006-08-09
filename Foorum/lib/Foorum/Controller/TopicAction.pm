package Foorum::Controller::TopicAction;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use Data::Dumper;

sub lock_or_top_or_elite : Regex('^forum/(\d+)/(\d+)/(un)?(top|elite|lock)$') {
    my ( $self, $c ) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    my $topic_id = $c->req->snippets->[1];
    my $is_un    = $c->req->snippets->[2];
    my $action   = $c->req->snippets->[3];
    
    my $topic = $c->model('DBIC')->resultset('Topic')->search( {
        topic_id => $topic_id,
        forum_id => $forum_id,
    }, {
        columns => ['author_id'],
    } )->first;
    
    $c->detach('/print_error', [ 'Non-existent topic' ]) unless ($topic);
    
    # check policy
    unless ($c->user->{is_moderator} or ($action eq 'lock' and $topic->author_id == $c->user->user_id) ) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ] );
    }
    
    my $status = ($is_un)?'0':'1';
    
    my $update_col;
    if ($action eq 'top') {
        $update_col = 'sticky';
    } elsif ($action eq 'lock') {
        $update_col = 'closed';
    } elsif ($action eq 'elite') {
        $update_col = 'elite';
    }
    
    $c->model('DBIC::Topic')->search( {
        topic_id => $topic_id,
        forum_id => $forum_id,
    } )->update( {
        $update_col => $status,
    } );
    
    $c->forward('/print_message', [ {
        msg => 'OK',
        uri => "/forum/$forum_id",
    } ] );
}

1;
