package Foorum::Model::Forum;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub get {
    my ( $self, $c, $forum_code, $attr ) = @_;
    
    #my $RaiseError = (exists $attr->{RaiseError}) ? $attr->{RaiseError} : 1;
    my $forum_type = $attr->{forum_type} || 'classical';
    
    # if $forum_code is all numberic, that's forum_id
    # or else, it's forum_code
    my $where = ($forum_code =~ /^\d+$/) ? { forum_id => $forum_code } : 
                { forum_code => $forum_code, forum_type => $forum_type };
    
    my $forum = $c->model('DBIC')->resultset('Forum')->find( $where );
    $forum->{forum_url} = $self->get_forum_url($c, $forum) if ($forum);

    return $forum if ($attr->{level} eq 'data'); # do NOT check permisson, see also RSS.pm
    
    # print error if the forum_id is non-exist
    $c->detach('/print_error', [ 'Non-existent forum' ]) unless ($forum);
    
    my $forum_id = $forum->forum_id;
    # check policy
    if ($c->user_exists and $c->model('Policy')->is_blocked( $c, $forum_id )) {
        $c->detach('/print_error', [ 'ERROR_USER_BLOCKED' ]);
    }
    if ($forum->policy eq 'private') {
        unless ($c->user_exists) {
            $c->res->redirect('/login');
            $c->detach('/end'); # guess we'd better use Chained
        }
        
        unless ($c->model('Policy')->is_user( $c, $forum_id )) {
            if ($c->model('Policy')->is_pending($c, $forum_id)) {
                $c->detach('/print_error', [ 'ERROR_USER_PENDING' ]);
            } elsif ($c->model('Policy')->is_rejected($c, $forum_id)) {
                $c->detach('/print_error', [ 'ERROR_USER_REJECTED' ]);
            } else {
                $c->detach('/forum/join_us', [ $forum ]);
            }
        }
    }

    $c->stash->{forum} = $forum;
    
    return $forum;
}

sub get_forum_url {
    my ($self, $c, $forum) = @_;
    
    my $forum_url = '/forum/' . $forum->forum_code;

    return $forum_url;
}

sub remove_forum {
    my ($self, $c, $forum_id) = @_;
    
    $c->model('DBIC::Forum')->search( {
        forum_id => $forum_id,
    } )->delete;
    $c->model('Policy')->remove_user_role( $c, {
        field => $forum_id,
    } );
    
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

sub merge_forums {
    my ($self, $c, $info) = @_;

    my $from_id = $info->{from_id} or return 0;
    my $to_id   = $info->{to_id} or return 0;

    my $old_forum = $c->model('DBIC::Forum')->find( { forum_id => $from_id } );
    return unless ($old_forum);
    my $new_forum = $c->model('DBIC::Forum')->find( { forum_id => $to_id } );
    return unless ($new_forum);
    $c->model('DBIC::Forum')->search( {
        forum_id => $from_id,
    } )->delete;
    # update new
    my $total_topics = $old_forum->total_topics;
    my $total_replies = $old_forum->total_replies;
    my $total_members = $old_forum->total_members;
    my @extra_cols;
    if ($new_forum->policy eq 'private') {
        @extra_cols = ('total_members', \"total_members + $total_members");
    }
    $c->model('DBIC::Forum')->search( {
        forum_id => $to_id,
    } )->update( {
        total_topics  => \"total_topics  + $total_topics",
        total_replies => \"total_replies + $total_replies",
        @extra_cols,
    } );
    $c->model('Policy')->remove_user_role( $c, {
        field => $from_id,
    } );
    
    # topics
    $c->model('DBIC::Topic')->search( {
        forum_id => $from_id,
    } )->update( {
        forum_id => $to_id,
    } );
    
    # get all poll_ids
    $c->model('DBIC::Poll')->search( {
        forum_id => $from_id,
    } )->update( {
        forum_id => $to_id,
    } );
    
    # comment and star
    $c->model('DBIC::Comment')->search( {
        forum_id => $from_id,
    } )->update( {
        forum_id => $to_id,
    } );
    
    # for upload
    $c->model('Upload')->change_for_forum($c, $info);
    
    return 1;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
