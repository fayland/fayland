package Foorum::Controller::ForumAdmin;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Foorum::Utils qw/is_color/;

sub home : LocalRegex('^(\d+)$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    &_check_policy( $self, $c, $forum );
    
    $c->stash->{template} = 'forumadmin/index.html';
}

sub basic : LocalRegex('^(\d+)/basic$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash->{template} = 'forumadmin/basic.html';
    
    return unless ($c->req->param('process'));
        
    &_check_policy( $self, $c, $forum );
    
    # todo
    
}

sub style : LocalRegex('^(\d+)/style$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash->{template} = 'forumadmin/style.html';
    
    return unless ($c->req->param('submit'));
    
    &_check_policy( $self, $c, $forum );
    
    my %params = $c->req->params;
    # validate the %params;

}

sub _check_policy {
    my ( $self, $c, $forum ) = @_;
    
    unless ($c->forward('/policy/is_admin', [ $forum->forum_id ])) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
}

1;
