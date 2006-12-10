package Foorum::Model::Forum;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub remove_forum {
    my ($self, $c, $forum_id) = @_;
    
    $c->model('DBIC::Forum')->search( {
        forum_id => $forum_id,
    } )->delete;
    $c->model('DBIC::UserRole')->search( {
        field => $forum_id,
    } )->delete;
    
    # get all topic_ids
    my @topic_ids;
    my $tp_rs = $c->model('DBIC::Topic')->search( {
        forum_id => $forum_id,
    }, {
        columns => ['topic_id'],
    } );
    while (my $r = $tp_rs->next) {
        push @topic_ids, $r->topic_id;
    }
    $c->model('DBIC::Topic')->search( {
        forum_id => $forum_id,
    } )->delete;
    
    # get all poll_ids
    my @poll_ids;
    my $pl_rs = $c->model('DBIC::Poll')->search( {
        forum_id => $forum_id,
    }, {
        columns => ['poll_id'],
    } );
    while (my $r = $pl_rs->next) {
        push @poll_ids, $r->poll_id;
    }
    $c->model('DBIC::Poll')->search( {
        forum_id => $forum_id,
    } )->delete;
    if (scalar @poll_ids) {
        $c->model('DBIC::PollOption')->search( {
            poll_id => { 'IN', \@poll_ids },
        } )->delete;
        $c->model('DBIC::PollResult')->search( {
            poll_id => { 'IN', \@poll_ids },
        } )->delete;
    }
    
    # comment and star
    if (scalar @topic_ids) {
        $c->model('DBIC::Comment')->search( {
            object_type => 'thread',
            object_id   => { 'IN', \@topic_ids },
        } )->delete;
        $c->model('DBIC::Star')->search( {
            object_type => 'topic',
            object_id   => { 'IN', \@topic_ids },
        } )->delete;
    }
    if (scalar @poll_ids) {
        $c->model('DBIC::Comment')->search( {
            object_type => 'poll',
            object_id   => { 'IN', \@poll_ids },
        } )->delete;
        $c->model('DBIC::Star')->search( {
            object_type => 'poll',
            object_id   => { 'IN', \@poll_ids },
        } )->delete;
    }
    
    # for upload
    $c->model('Upload')->remove_for_forum($c, $forum_id);
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
