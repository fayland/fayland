package Foorum::Model::Topic;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub get {
    my ( $self, $c, $forum_id, $topic_id, $attrs ) = @_;
    
    my @extra_attrs;
    push @extra_attrs, ( prefetch => ['author'] ) if ($attrs->{with_author});
    
    my $topic = $c->model('DBIC')->resultset('Topic')->search( {
        topic_id => $topic_id,
        forum_id => $forum_id,
    }, {
        @extra_attrs,
    } )->first;
    
    # print error if the topic is non-exist
    $c->detach('/print_error', [ 'Non-existent topic' ]) unless ($topic);
    
    $c->stash->{topic} = $topic;
    
    return $topic;
}

sub remove {
    my ($self, $c, $forum_id, $topic_id) = @_;
    
    # delete topic
    $c->model('DBIC::Topic')->search( { topic_id => $topic_id } )->delete;

    # delete comments with upload
    my $total_replies = -1; # since one comment is topic indeed.
    my $comment_rs = $c->model('DBIC::Comment')->search( {
        object_type => 'thread',
        object_id   => $topic_id,
    } );
    while (my $comment = $comment_rs->next) {
        $c->model('Comment')->remove($c, $comment);
        $total_replies++;
    }
        
    # log action
    $c->model('Log')->log_action($c, { action => 'delete', object_type => 'topic', object_id => $topic_id, forum_id => $forum_id } );
        
    # update last
    my $lastest = $c->model('DBIC')->resultset('Topic')->find( {
        forum_id => $forum_id
    }, {
        order_by => 'last_update_date DESC',
    } );
    my $last_post_id = $lastest ? $lastest->topic_id : 0;
    $c->model('DBIC::Forum')->search( {
        forum_id => $forum_id,
    } )->update( {
        total_topics => \'total_topics - 1',
        last_post_id => $last_post_id,
        total_replies => \"total_replies - $total_replies",
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
