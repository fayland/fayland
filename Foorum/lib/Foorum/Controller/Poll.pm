package Foorum::Controller::Poll;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub start : Regex('^forum/(\d+)/poll/new$') {
    my ($self, $c) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);

    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->controller('Get')->forum($c, $forum_id);

    $c->stash->{template} = 'poll/new.html';
    return unless ($c->req->param('submit'));

    # validation
    
    # insert record into table
    my $poll = $c->model('DBIC::Poll')->create( {
        author_id => $c->user->user_id,
	multi     => $c->req->param('multi'),
	anonymous => 0, # disable it for this moment
	vote_no   => 0,
	time      => time(),
	duration  => $duration,
	title     => $c->req->param('title'),
    } );
    my $poll_id = $poll->poll_id;
    # get all options
    my $option_no = $c->req->param('option_no');
    foreach (1 .. $option_no) {
	$c->model('DBIC::PollOption')->create( {
	    poll_id => $poll_id,
	    text    => $c->req->param("option$option_no"),
	    vote_no => 0,
	} );
    }

    $c->res->redirect("/forum/$forum_id/poll/$poll_id");
}

sub poll : Regex('^forum/(\d+)/poll/(\d+)(/page=(\d+))?$') {
    my ($self, $c) = @_;

    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->controller('Get')->forum($c, $forum_id);
    my $poll_id  = $c->req->snippets->[1];
    my $page     = $c->req->snippets->[2];

    $c->stash( {
	template => 'poll/index.html',
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
