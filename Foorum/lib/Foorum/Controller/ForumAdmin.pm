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
    
    # execute validation.
    $c->form(
        bg_color => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        alink => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        vlink => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        hlink => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        tablebordercolor => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        titlecolor => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        titlefont => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumcolor1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumfont1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumcolor2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumfont2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replycolor1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replyfont1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replycolor2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replyfont2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        misccolor1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        miscfont1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        misccolor2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        miscfont2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        highlight => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        semilight => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        tablewidth => [ ['BETWEEN', 70, 100] ],
        bg_image  => [ 'HTTP_URL', ['REGEX', qr/^(gif|jpe?g|png)$/ ] ],
    );

    return if ($c->form->has_error);

    &_check_policy( $self, $c, $forum );
    
}

sub _check_policy {
    my ( $self, $c, $forum ) = @_;
    
    unless ($c->forward('/policy/is_admin', [ $forum->forum_id ])) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
