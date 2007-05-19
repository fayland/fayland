package Foorum::Controller::Comment;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub post : Local {
    my ( $self, $c ) = @_;

    return $c->res->redirect('/login') unless ($c->user_exists);
    
    # get object_type and object_id from c.req.referer
    my $path = $c->req->referer || '/';
    my ($object_id, $object_type, $forum_id) = $c->model('Object')->get_object_from_url($c, $path);
    return $c->res->redirect($path) unless ($object_id and $object_type);
    
    # execute validation.
    _validate($c);
    
    my $upload = $c->req->upload('upload');
    my $upload_id = 0;
    if ($upload) {
        $upload_id = $c->model('Upload')->add_file($c, $upload, { forum_id => $forum_id } );
        unless ($upload_id) {
            $c->detach('/print_error', [ $c->stash->{upload_error} ] );
        }
    }
    
    # create record
    $c->model('Comment')->create($c, {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
        upload_id   => $upload_id,
    } );
    
    $c->res->redirect($path);
}

sub reply : LocalRegex('^(\d+)/reply$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    $c->stash->{template} = 'comment/reply.html';
    
    my $comment_id = $c->req->snippets->[0];
    my $comment  = $c->forward('/get/comment', [ $comment_id ] );
    
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
        $upload_id = $c->model('Upload')->add_file($c, $upload, { forum_id => $comment->forum_id } );
        unless ($upload_id) {
            return $c->set_invalid_form( upload => $c->stash->{upload_error} );
        }
    }
    
    my ($object_id, $object_type, $forum_id) = 
       ($comment->object_id, $comment->object_type, $comment->forum_id);
    my $info = {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
        upload_id   => $upload_id,
    };
    
    # create record
    $c->model('Comment')->create($c, $info );
    
    my $path = $c->model('Object')->get_url_from_object($c, $info);
    
    $c->forward('/print_message', [ {
        msg => 'Post Reply OK',
        url => $path,
    } ] );
}

sub edit : LocalRegex('^(\d+)/edit$') {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);

    my $comment_id = $c->req->snippets->[0];
    my $comment  = $c->forward('/get/comment', [ $comment_id ] );
    
    # permission
    if ($c->user->user_id != $comment->author_id and not $c->model('Policy')->is_moderator($c, 'site')) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
    
    $c->stash->{template} = 'comment/edit.html';
    
    # edit upload
    my $old_upload;
    if ($comment->upload_id) {
        $old_upload = $c->model('DBIC::Upload')->find( { upload_id => $comment->upload_id } );
    }
    $c->stash->{upload} = $old_upload;
    
    return unless ($c->req->method eq 'POST');
    
    # execute validation.
    $c->form(
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);

    my $new_upload = $c->req->upload('upload');
    my $upload_id = $comment->upload_id;
    if (($c->req->param('attachment_action') eq 'delete') or $new_upload) {
        # delete old upload
        if ($old_upload) {
            $c->model('Upload')->remove_by_upload( $c, $old_upload );
            $upload_id = 0;
        }
        # add new upload
        if ($new_upload) {
            $upload_id = $c->model('Upload')->add_file($c, $new_upload, { forum_id => $comment->forum_id } );
            unless ($upload_id) {
                return $c->set_invalid_form( upload => $c->stash->{upload_error} );
            }
        }
    }

    $comment->update( {
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        update_on   => \"NOW()",
        post_ip     => $c->req->address,
        upload_id   => $upload_id,
    } );
    
    my ($object_id, $object_type, $forum_id) = 
       ($comment->object_id, $comment->object_type, $comment->forum_id);
    my $info = {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
    };
    my $path = $c->model('Object')->get_url_from_object($c, $info);
    
    $c->forward('/print_message', [ {
        msg => 'Edit Reply OK',
        url => $path,
    } ] );
}

sub delete : LocalRegex('^(\d+)/delete$') {
    my ( $self, $c ) = @_;

    my $comment_id = $c->req->snippets->[0];
    my $comment  = $c->forward('/get/comment', [ $comment_id ] );
    
    # permission
    if ($c->user->user_id != $comment->author_id and not $c->model('Policy')->is_moderator($c, 'site')) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
    
    # delete comment
    $c->model('Comment')->remove($c, $comment);
    
    my ($object_id, $object_type, $forum_id) = 
       ($comment->object_id, $comment->object_type, $comment->forum_id);
    my $info = {
        object_type => $object_type,
        object_id   => $object_id,
        forum_id    => $forum_id,
    };
    my $path = $c->model('Object')->get_url_from_object($c, $info);
    
    $c->forward('/print_message', [ {
        msg => 'Delete Reply OK',
        url => $path,
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
