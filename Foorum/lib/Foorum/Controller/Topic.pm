package Foorum::Controller::Topic;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use Data::Dumper;

sub topic : Regex('^forum/(\d+)/(\d+)(/page=(\d+))?$') {
    my ( $self, $c ) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $topic_id = $c->req->snippets->[1];
    my $page_no  = $c->req->snippets->[3];
    $page_no = 1 unless ($page_no and $page_no =~ /^\d+$/);
    
    # get the forum information
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    # get the topic
    my $topic = $c->forward('/get/topic', [ $forum_id, $topic_id ]);
    $topic->update( {
        hit => $topic->hit + 1,
    } );
    
    my $it = $c->model('DBIC')->resultset('Comment')->search( {
        object_type => 'thread',
        object_id   => $topic_id,
    }, {
        order_by => 'post_on',
        rows => $c->config->{per_page}->{topic},
        page => $page_no,
        prefetch => ['author'],
    } );
    
    my @comments = $it->all;
    $c->stash->{comments} = \@comments;
	$c->stash->{pager} = $it->pager;

    $c->stash->{template} = 'topic/index.html';
}

sub create : Regex('^forum/(\d+)/topic$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    &_check_policy($self, $c);
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash( {
        template => 'topic/create.html',
        action   => 'create',
    } );
    
    return unless ($c->req->param('process'));
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);
    
    # create record 
    my $topic = $c->model('DBIC')->resultset('Topic')->create( {
        forum_id  => $forum_id,
        title     => $c->req->param('title'),
        author_id => $c->user->user_id,
        last_updator_id  => $c->user->user_id,
        last_update_date => DateTime->now,
    } );
    
    my $comment = $c->model('DBIC')->resultset('Comment')->create( {
        object_type => 'thread',
        object_id   => $topic->topic_id,
        author_id   => $c->user->user_id,
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        post_on     => DateTime->now,
        post_ip     => $c->req->address,
        reply_to    => 0,
    } );
    
    # update forum
    $forum->update( {
        total_topics => $forum->total_topics + 1,
        last_post_id => $topic->topic_id,
    } );
    
    $c->res->redirect("/forum/$forum_id/" . $topic->topic_id);
}

sub reply : Regex('^forum/(\d+)/(\d+)(/(\d+))?/reply$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    &_check_policy( $self, $c );
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    my $topic_id = $c->req->snippets->[1];
    my $topic = $c->forward('/get/topic', [ $forum_id, $topic_id ]);
    my $comment_id = $c->req->snippets->[3];
    
    $c->stash( {
        template => 'topic/create.html',
        action   => 'reply',
    } );
    
    return unless ($c->req->param('process'));
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);
    
    $comment_id = $topic_id unless ($comment_id);
    my $comment = $c->model('DBIC')->resultset('Comment')->create( {
        object_type => 'thread',
        object_id   => $topic_id,
        author_id   => $c->user->user_id,
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        post_on     => DateTime->now,
        post_ip     => $c->req->address,
        reply_to    => $comment_id,
    } );

    # update forum and topic
    $forum->update( {
        total_replies => $forum->total_replies + 1,
        last_post_id  => $topic->topic_id,
    } );
    $topic->update( {
        total_replies => $topic->total_replies + 1,
        last_update_date => DateTime->now,
        last_updator_id  => $c->user->user_id,
    } );
    
    $c->forward('/print_message', [ {
        msg => 'Post Reply OK',
        uri => "/forum/$forum_id/$topic_id",
    } ] );
}

sub edit : Regex('^forum/(\d+)/(\d+)/(\d+)/edit$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    &_check_policy($self, $c);
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    my $topic_id = $c->req->snippets->[1];
    my $topic = $c->forward('/get/topic', [ $forum_id, $topic_id ]);
    my $comment_id = $c->req->snippets->[2];
    my $comment  = $c->forward('/get/comment', [ $comment_id, 'thread', $topic_id ] );
    
    $c->stash( {
        template => 'topic/create.html',
        action   => 'edit',
    } );
    
    return unless ($c->req->param('process'));
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);
     ;
    $comment->update( {
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        update_on   => DateTime->now,
        post_ip     => $c->req->address,
    } );
    
    if ($comment->reply_to == 0 and $topic->title ne $c->req->param('title')) {
        $topic->update( {
            title => c->req->param('$titl'),,
        } );
    }
    
    $c->forward('/print_message', [ {
        msg => 'Edit Reply OK',
        uri => "/forum/$forum_id/$topic_id",
    } ] );
}

sub delete : Regex('^forum/(\d+)/(\d+)/(\d+)/delete$') {
    my ( $self, $c ) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    my $topic_id = $c->req->snippets->[1];
    my $comment_id = $c->req->snippets->[2];
    my $comment  = $c->forward('/get/comment', [ $comment_id, 'thread', $topic_id ] );
    
    my $uri;
    if ($comment->reply_to == 0) {
        # delete topic
        my $delete_count = $c->model('DBIC')->resultset('Comment')->search( {
            object_type => 'thread',
            object_id   => $topic_id,
        } )->delete_all;
        
        $c->log->debug("Delete count:" . Dumper($delete_count));
        
        $uri = "/forum/$forum_id";
        
        # update last
        my $lastest = $c->model('DBIC')->resultset('Topic')->search( {
            forum_id => $forum_id
        }, {
            order_by => 'last_update_date DESC',
        } )->first;
        my @extra_cols = ($lastest)?(last_post_id => $lastest->topic_id):(last_post_id => '');
        $forum->update( {
            total_topics => $forum->total_topics - 1,
            @extra_cols,
        } );
    } else {
        # delete comment
        my $comment = $c->model('DBIC')->resultset('Comment')->search( {
            comment_id => $comment_id,
        } )->delete;
        
        $uri = "/forum/$forum_id/$topic_id";
        
        # update topic
        my $lastest = $c->model('DBIC')->resultset('Comment')->search( {
            object_type => 'thread',
            object_id   => $topic_id,
        }, {
            order_by => 'post_on DESC',
        } )->first;
        
        my @extra_cols;
        if ($lastest) {
            @extra_cols = (
                last_updator_id  => $lastest->author_id,
                last_update_date => $lastest->update_on || $lastest->post_on,
            );
        } else {
            @extra_cols = (
                last_updator_id  => '',
                last_update_date => '',
            );
        }
        $c->model('DBIC')->resultset('Topic')->search( {
            topic_id => $topic_id,
        } )->update( {
            total_replies => \"total_replies - 1",
            @extra_cols,
        } );
        
        # update forum
        $forum->update( {
            total_replies => $forum->total_replies - 1,
        } );
    }
    
    $c->forward('/print_message', [ {
        msg => 'Delete Reply OK',
        uri => $uri,
    } ] );
}

sub _check_policy {
    my ( $self, $c ) = @_;
    
    # check policy
    if ($c->user->status eq 'banned' or $c->user->status eq 'blocked') {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }

}

1;
