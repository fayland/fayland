package Foorum::Controller::Message;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime ();
use Data::Dumper;

sub auto : Private {
    my ( $self, $c ) = @_;
    
    unless ($c->user_exists) {
		$c->res->redirect('/login');
		return 0;
	}
	
	return 1;
}

sub default : Local {
    my ($self, $c) = @_;
    
    $c->forward('inbox');
}

sub compose : Local {
	my ( $self, $c ) = @_;
	
	$c->stash->{template} = 'message/compose.html';

    return unless ($c->req->param('process'));
    
    # cann't compose to yourself
    my $to = $c->req->param('to');
    if ($to eq $c->user->username) {
        $c->set_invalid_form( to => 'USER_THESAME' );
        return;
    }
    
    # execute validation.
    $c->form(
        to    => [qw/NOT_BLANK ASCII/,       [qw/LENGTH 4 20/] ],
        title => [qw/NOT_BLANK/,             [qw/LENGTH 1 80/] ],
        text  => [qw/NOT_BLANK/ ],
    );

    return if ($c->form->has_error);
    
    # check user exist
    my $rept = $c->model('DBIC')->resultset('User')->search( { username => $to } )->first;
    unless ($rept) {
        $c->set_invalid_form( to => 'USER_NONEXIST' );
        return;
    }
    
    my $message = $c->model('DBIC')->resultset('Message')->create( {
        from_id => $c->user->user_id,
        to_id   => $rept->user_id,
        title   => $c->req->param('title'),
        text    => $c->req->param('text'),
        post_on => DateTime->now,
        post_ip => $c->req->address,
    } );
    
    # add unread
    $c->model('DBIC')->resultset('MessageUnread')->create( {
        message_id => $message->message_id,
        user_id    => $rept->user_id,
    } );
	
	$c->res->redirect('/message/outbox');
}

sub inbox : Local {
    my ($self, $c, $page) = @_;
    
    # get page_no
    my $page_no = 1;
    if ($page and $page =~ /^page=(\d+)$/) {
        $page_no = $1;
    }
    
    my $it = $c->model('DBIC')->resultset('Message')->search( {
        to_id => $c->user->user_id,
    } , {
        columns => [ 'message_id', 'title', 'post_on', ],
        prefetch => ['sender'],
        order_by => 'post_on DESC',
        rows    => $c->config->{per_page}->{message},
        page    => $page_no,
    } );
    my @messages = $it->all;
    $c->stash->{messages} = \@messages;
    $c->stash->{pager} = $it->pager;
    
    $c->stash->{template} = 'message/inbox.html';
}

sub outbox : Local {
    my ($self, $c, $page) = @_;
    
    # get page_no
    my $page_no = 1;
    if ($page and $page =~ /^page=(\d+)$/) {
        $page_no = $1;
    }
    
    my $it = $c->model('DBIC')->resultset('Message')->search( {
        from_id => $c->user->user_id,
    } , {
        columns => [ 'message_id', 'title', 'post_on', ],
        prefetch => ['recipient'],
        order_by => 'post_on DESC',
        rows    => $c->config->{per_page}->{message},
        page    => $page_no,
    } );
    my @messages = $it->all;
    $c->stash->{messages} = \@messages;
    $c->stash->{pager} = $it->pager;
    
    $c->stash->{template} = 'message/outbox.html';
}

sub message : LocalRegex('^(\d+)$') {
    my ($self, $c) = @_;
    
    my $message_id = $c->req->snippets->[0];
    
    my $message = $c->model('DBIC')->resultset('Message')->search( {
        message_id => $message_id,
    }, {
        prefetch => ['sender', 'recipient'],
    } )->first;
    $c->stash->{message} = $message;
    
    # mark as read
    $c->model('DBIC')->resultset('MessageUnread')->search( {
        message_id => $message_id,
        user_id    => $c->user->user_id,
    } )->delete;
    
    $c->stash->{template} = 'message/message.html';
}

1;