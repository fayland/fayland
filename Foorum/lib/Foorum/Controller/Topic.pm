package Foorum::Controller::Topic;

use strict;
use warnings;
use base 'Catalyst::Controller';
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
    
    # 'star' status
    if ($c->user_exists) {
        $c->stash->{has_star} = $c->model('DBIC::Star')->count( {
            user_id => $c->user->user_id,
            object_type => 'topic',
            object_id   => $topic_id,
        } );
    }        
    
    # get comments
    $c->model('Comment')->get_comments_by_object($c, {
        object_type => 'thread',
        object_id   => $topic_id,
        page => $page_no,
    } );

    $c->stash->{template} = 'topic/index.html';
}

sub create : Regex('^forum/(\d+)/topic/new$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    &_check_policy($self, $c);
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash( {
        template => 'topic/create.html',
        action   => 'create',
    } );
    
    return unless ($c->req->method eq 'POST');
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);

    my $upload = $c->req->upload('upload');
    my $upload_id = 0;
    if ($upload) {
        $upload_id = $c->model('Upload')->add_file($c, $upload, { forum_id => $forum_id } );
        unless ($upload_id) {
            return $c->set_invalid_form( upload => $c->stash->{upload_error} );
        }
    }
    
    # create record 
    my $topic = $c->model('DBIC')->resultset('Topic')->create( {
        forum_id  => $forum_id,
        title     => $c->req->param('title'),
        author_id => $c->user->user_id,
        last_updator_id  => $c->user->user_id,
        last_update_date => \"NOW()",
    } );
    $c->clear_cached_page( '/forum');
    $c->clear_cached_page( "/forum/$forum_id/rss" );
    $c->clear_cached_page( '/forum/recent' );
    $c->clear_cached_page( '/forum/recent/rss' );
    $c->clear_cached_page( '/forum/recent/elite' );
    $c->clear_cached_page( '/forum/recent/elite/rss' );
    
    my $comment = $c->model('DBIC')->resultset('Comment')->create( {
        object_type => 'thread',
        object_id   => $topic->topic_id,
        author_id   => $c->user->user_id,
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        post_on     => \"NOW()",
        post_ip     => $c->req->address,
        reply_to    => 0,
        forum_id    => $forum_id,
        upload_id   => $upload_id,
    } );
    
    # update user stat
    $c->user->obj->update( {
        threads => \"threads + 1",
        last_post_id => $topic->topic_id,
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
    
    # topic is closed or not
    $c->detach('/print_error', [ 'ERROR_CLOSED' ]) if ($topic->closed);
    
    $c->stash->{template} = 'comment/reply.html';
    
    unless ($c->req->method eq 'POST') {
        my $comment  = $c->forward('/get/comment', [ $comment_id, 'thread', $topic_id ] ) if ($comment_id);
        return;
    }
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);
    
    my $upload = $c->req->upload('upload');
    my $upload_id = 0;
    if ($upload) {
        $upload_id = $c->model('Upload')->add_file($c, $upload, { forum_id => $forum_id } );
        unless ($upload_id) {
            return $c->set_invalid_form( upload => $c->stash->{upload_error} );
        }
    }
    
    $comment_id = $topic_id unless ($comment_id);
    my $comment = $c->model('DBIC')->resultset('Comment')->create( {
        object_type => 'thread',
        object_id   => $topic_id,
        author_id   => $c->user->user_id,
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        post_on     => \"NOW()",
        post_ip     => $c->req->address,
        reply_to    => $comment_id,
        forum_id    => $forum_id,
        upload_id   => $upload_id,
    } );

    # update forum and topic
    $forum->update( {
        total_replies => $forum->total_replies + 1,
        last_post_id  => $topic->topic_id,
    } );
    $topic->update( {
        total_replies => $topic->total_replies + 1,
        last_update_date => \"NOW()",
        last_updator_id  => $c->user->user_id,
    } );
    
    # update user stat
    $c->user->obj->update( {
        replies => \"replies + 1",
        last_post_id => $topic_id,
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
    
    # permission
    if ($c->user->user_id != $comment->author_id and not $c->model('Policy')->is_moderator($c, $forum_id)) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
    
    $c->stash->{template} = 'comment/edit.html';
    
    return unless ($c->req->method eq 'POST');
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);

    $comment->update( {
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        update_on   => \"NOW()",
        post_ip     => $c->req->address,
    } );
    
    if ($comment->reply_to == 0 and $topic->title ne $c->req->param('title')) {
        $topic->update( {
            title => $c->req->param('title'),
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
    
    # permission
    if ($c->user->user_id =! $comment->author_id and not $c->model('Policy')->is_moderator($c, $forum_id)) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
    
    my $uri;
    if ($comment->reply_to == 0) {
        # delete topic
        my $delete_count = $c->model('DBIC')->resultset('Comment')->search( {
            object_type => 'thread',
            object_id   => $topic_id,
        } )->delete;
        
        $c->log->debug("Delete count:" . Dumper($delete_count));
        
        $uri = "/forum/$forum_id";
        
        # update last
        my $lastest = $c->model('DBIC')->resultset('Topic')->find( {
            forum_id => $forum_id
        }, {
            order_by => 'last_update_date DESC',
        } );
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
        my $lastest = $c->model('DBIC')->resultset('Comment')->find( {
            object_type => 'thread',
            object_id   => $topic_id,
        }, {
            order_by => 'post_on DESC',
        } );
        
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

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
