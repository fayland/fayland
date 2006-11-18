package Foorum::Controller::Comment;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub post_comment : Local {
    my ( $self, $c ) = @_;

    return $c->res->redirect('/login') unless ($c->user_exists);
    
    # get object_type and object_id from c.req.referer
    my $path = $c->req->referer;
    my ($object_id, $object_type, $forum_id) = $c->model('Comment')->get_object_from_url($c, $path);
    return $c->res->redirect($path) unless ($object_id and $object_type);
    
    # execute validation.
    _validate($c);
    
    # create record
    $c->model('Comment')->create_a_comment($c, {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
    } );
    
    $c->res->redirect($path);
}

sub reply : LocalRegex('^(\d+)/reply$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    $c->stash->{template} = 'comment/reply.html';
    
    my $comment_id = $c->req->snippets->[0];
    my $comment  = $c->forward('/get/comment', [ $comment_id ] );
    
    return unless ($c->req->param('process'));
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);
    
    my ($object_id, $object_type, $forum_id) = 
       ($comment->object_id, $comment->object_type, $comment->forum_id);
    my $info = {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
    };
    
    # create record
    $c->model('Comment')->create_a_comment($c, $info );
    
    my $path = $c->model('Comment')->get_url_from_object($c, $info);
    
    $c->forward('/print_message', [ {
        msg => 'Post Reply OK',
        uri => $path,
    } ] );
}

sub edit : LocalRegex('^(\d+)/edit$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);

    my $comment_id = $c->req->snippets->[0];
    my $comment  = $c->forward('/get/comment', [ $comment_id ] );
    
    # permission
    if ($c->user->user_id =! $comment->author_id and not $c->model('Policy')->is_moderator($c, 'site')) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
    
    $c->stash->{template} = 'comment/edit.html';
    return unless ($c->req->param('process'));
    
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
    
    my ($object_id, $object_type, $forum_id) = 
       ($comment->object_id, $comment->object_type, $comment->forum_id);
    my $info = {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
    };
    my $path = $c->model('Comment')->get_url_from_object($c, $info);
    
    $c->forward('/print_message', [ {
        msg => 'Edit Reply OK',
        uri => $path,
    } ] );
}

sub delete : LocalRegex('^(\d+)/delete$') {
    my ( $self, $c ) = @_;

    my $comment_id = $c->req->snippets->[0];
    my $comment  = $c->forward('/get/comment', [ $comment_id ] );
    
    # permission
    if ($c->user->user_id =! $comment->author_id and not $c->model('Policy')->is_moderator($c, 'site')) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
    
    # delete comment
    $c->model('DBIC')->resultset('Comment')->search( {
        comment_id => $comment_id,
    } )->delete;
    
    my ($object_id, $object_type, $forum_id) = 
       ($comment->object_id, $comment->object_type, $comment->forum_id);
    my $info = {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
    };
    my $path = $c->model('Comment')->get_url_from_object($c, $info);
    
    $c->forward('/print_message', [ {
        msg => 'Delete Reply OK',
        uri => $path,
    } ] );
}

sub _validate {
    my ( $c ) = @_;

    my $title = $c->req->param('title');
    my $text  = $c->req->param('text');
    unless ($title and length($title) < 80) {
        $c->detach('/print_error', [ 'ERROR_TITLE_LENGTH' ]);
    }
    unless ($text) {
        $c->detach('/print_error', [ 'ERROR_TEXT_REQUIRED' ]);
    }
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
