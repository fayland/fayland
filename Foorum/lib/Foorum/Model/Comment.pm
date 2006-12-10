package Foorum::Model::Comment;

use strict;
use warnings;
use base 'Catalyst::Model';
use Foorum::Utils qw/get_page_no_from_url/;
use Data::Dumper;
use Switch;

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

sub get_object_from_url {
    my ($self, $c, $path) = @_;
    
    my ($object_id, $object_type);
    my $forum_id = 0;
    # 1. poll, eg: /forum/1/poll/2
    if ($path =~ /\/forum\/(\d+)\/poll\/(\d+)/) {
        $forum_id  = $1;
        $object_id = $2; # poll_id
        $object_type = 'poll';
    }
    # 2. user profile, eg: /u/fayland
    elsif ($path =~ /\/u\/(\w+)/) {
        my $user_id = $c->model('User')->get_user_id_from_username($c, $1);
        $object_id  = $user_id;
        $object_type = 'user_profile';
    }
    
    return ($object_id, $object_type, $forum_id);
}

sub get_url_from_object {
    my ($self, $c, $info) = @_;
    
    my $object_type = $info->{object_type};
    my $object_id   = $info->{object_id};
    my $forum_id    = $info->{forum_id};
    
    switch ($object_type) {
        case 'poll' { return "/forum/$forum_id/poll/$object_id"; }
        case 'user_profile' {
            my $username = $c->model('User')->get_username_from_user_id($c, $object_id);
            return "/u/$username" if ($username);
        }
    }
}

sub create_a_comment {
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
    
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
