package Foorum::Controller::Get;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub forum : Private {
    my ( $self, $c, $forum_id ) = @_;
    
    my $forum = $c->model('DBIC')->resultset('Forum')->single( {
        forum_id => $forum_id,
    });
    
    # print error if the forum_id is non-exist
    $c->detach('/print_error', [ 'Non-existent forum' ]) unless ($forum);
    
    # check policy
    if ($c->user_exists and $c->forward('/policy/is_blocked', [ $forum_id ])) {
        $c->detach('/print_error', [ 'ERROR_USER_BLOCKED' ]);
    }
    if ($forum->policy eq 'private') {
        return $c->res->redirect('/login') unless ($c->user_exists);
        
        unless ($c->forward('/policy/is_user', [ $forum_id ] )) {
            $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
        }
    }

    $c->stash->{forum} = $forum;
    
    return $forum;
}

sub topic : Private {
    my ( $self, $c, $forum_id, $topic_id ) = @_;
    
    my $topic = $c->model('DBIC')->resultset('Topic')->search( {
        topic_id => $topic_id,
        forum_id => $forum_id,
    }, {
        prefetch => ['author'],
    } )->first;
    
    # print error if the topic is non-exist
    $c->detach('/print_error', [ 'Non-existent topic' ]) unless ($topic);
    
    $c->stash->{topic} = $topic;
    
    return $topic;
}

sub comment : Private {
    my ( $self, $c, $comment_id, $object_type, $object_id ) = @_;
    
    my @extra_cols;
    push @extra_cols, ( object_type => $object_type ) if ($object_type);
    push @extra_cols, ( object_id   => $object_id ) if ($object_id);
    
    my $comment = $c->model('DBIC')->resultset('Comment')->search( {
        comment_id => $comment_id,
        @extra_cols,
    }, {
        prefetch => ['author'],
    } )->first;
    
    # print error if the comment is non-exist
    $c->detach('/print_error', [ 'Non-existent comment' ]) unless ($comment);
    
    $c->stash->{comment} = $comment;
    
    return $comment;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;