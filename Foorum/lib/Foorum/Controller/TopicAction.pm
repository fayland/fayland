package Foorum::Controller::TopicAction;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub lock_or_sticky_or_elite :
    Regex('^forum/(\w+)/(\d+)/(un)?(sticky|elite|lock)$') {
    my ( $self, $c ) = @_;

    my $forum_code = $c->req->snippets->[0];
    my $forum      = $c->model('Forum')->get( $c, $forum_code );
    my $forum_id   = $forum->forum_id;
    $forum_code = $forum->forum_code;
    my $topic_id = $c->req->snippets->[1];
    my $is_un    = $c->req->snippets->[2];
    my $action   = $c->req->snippets->[3];

    my $topic = $c->model('Topic')->get( $c, $forum_id, $topic_id );

    # check policy
    unless ( $c->model('Policy')->is_moderator( $c, $forum_id )
        or ( $action eq 'lock' and $topic->author_id == $c->user->user_id ) )
    {
        $c->detach( '/print_error', ['ERROR_PERMISSION_DENIED'] );
    }

    my $status = ($is_un) ? '0' : '1';

    my $update_col;
    if ( $action eq 'sticky' ) {
        $update_col = 'sticky';
    } elsif ( $action eq 'lock' ) {
        $update_col = 'closed';
    } elsif ( $action eq 'elite' ) {
        $update_col = 'elite';
    }

    $c->model('DBIC::Topic')->search(
        {   topic_id => $topic_id,
            forum_id => $forum_id,
        }
    )->update( { $update_col => $status, } );

    $c->model('Log')->log_action(
        $c,
        {   action      => "$is_un$action",
            object_type => 'topic',
            object_id   => $topic_id,
            forum_id    => $forum_id,
            text        => $topic->title
        }
    );

    $c->clear_cached_page("/forum/$forum_id");
    $c->clear_cached_page("/forum/$forum_code") if ($forum_code);
    if ( $action eq 'elite' ) {
        $c->model('ClearCachedPage')->clear_when_topic_elite( $c, $forum );
    }

    $c->forward(
        '/print_message',
        [   {   msg => 'OK',
                url => $forum->{forum_url},
            }
        ]
    );
}

sub ban_or_unban_topic : Regex('^forum/(\w+)/(\d+)/(un)?ban$') {
    my ( $self, $c ) = @_;

    my $forum_code = $c->req->snippets->[0];
    my $forum      = $c->model('Forum')->get( $c, $forum_code );
    my $forum_id   = $forum->forum_id;
    $forum_code = $forum->forum_code;
    my $topic_id = $c->req->snippets->[1];
    my $is_un    = $c->req->snippets->[2];

    my $topic = $c->model('DBIC')->resultset('Topic')->find(
        {   forum_id => $forum_id,
            topic_id => $topic_id,
        }
    );
    $c->detach( '/print_error', ['Non-existent topic'] ) unless ($topic);

    # check policy
    unless ( $c->model('Policy')->is_moderator( $c, $forum_id ) ) {
        $c->detach( '/print_error', ['ERROR_PERMISSION_DENIED'] );
    }

    if ($is_un) {
        $topic->update( { status => 'healthy' } );
    } else {
        $topic->update( { status => 'banned' } );
    }

    $c->forward(
        '/print_message',
        [   {   msg => 'OK',
                url => $forum->{forum_url},
            }
        ]
    );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
