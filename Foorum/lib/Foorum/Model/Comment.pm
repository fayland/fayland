package Foorum::Model::Comment;

use strict;
use warnings;
use base 'Catalyst::Model';
use Foorum::Utils qw/get_page_no_from_url/;
use Data::Dumper;

sub get_comments_by_object {
    my ($self, $c, $info) = @_;
    
    my $object_type = $info->{object_type};
    my $object_id   = $info->{object_id};
    my $page        = $info->{page};
    $page = &get_page_no_from_url($c->req->path) unless ($page);
    
    my $it = $c->model('DBIC')->resultset('Comment')->search( {
        object_type => $object_type,
        object_id   => $object_id,
    }, {
        order_by => 'post_on',
        rows => $c->config->{per_page}->{topic},
        page => $page,
        prefetch => ['author', 'upload'],
    } );
    
    my @comments = $it->all;
    $c->stash->{comments} = \@comments;
	$c->stash->{comments_pager} = $it->pager;
}

sub create {
    my ($self, $c, $info) = @_;
    
    my $object_type = $info->{object_type};
    my $object_id   = $info->{object_id};
    my $forum_id    = $info->{forum_id} || 0;
    my $reply_to    = $info->{reply_to} || 0;
    
    my $comment = $c->model('DBIC')->resultset('Comment')->create( {
        object_type => $object_type,
        object_id   => $object_id,
        author_id   => $c->user->user_id,
        title       => $c->req->param('title'),
        text        => $c->req->param('text'),
        formatter   => 'text',
        post_on     => \"NOW()",
        post_ip     => $c->req->address,
        reply_to    => $reply_to,
        forum_id    => $forum_id,
        upload_id   => $info->{upload_id} || 0,
    } );
    return $comment;
}

sub remove {
    my ($self, $c, $comment) = @_;
    
    if ($comment->upload_id) {
        $c->model('Upload')->remove_file_by_upload_id($c, $comment->upload_id);
    }
    $c->model('DBIC::Comment')->search( { comment_id => $comment->comment_id } )->delete;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
