package Foorum::Controller::Forum;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub default : Private {
    my ($self, $c) = @_;
    
    my @forums = $c->model('DBIC')->resultset('Forum')->search( { }, {
        order_by => 'me.forum_id',
        prefetch => ['last_post'],
    } )->all;
    
    # get all moderators
    my @forum_ids;
    push @forum_ids, $_->forum_id foreach (@forums);
    my $roles = $c->forward('/policy/get_forum_moderators', [ \@forum_ids ] );
    $c->stash->{roles} = $roles;
    
    $c->stash->{forums} = \@forums;
    $c->stash->{template} = 'forum/board.html';

}

sub forum : LocalRegex('^(\d+)(/elite)?(/page=(\d+))?$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $is_elite = $c->req->snippets->[1];
    my $page_no  = $c->req->snippets->[3];
    if ($page_no and $page_no =~ /^\d+$/) {
        # set session
        $c->session->{'forum'}->{$forum_id}->{page} = $page_no;
    } else {
        $page_no = $c->session->{'forum'}->{$forum_id}->{page} || 1;
    }
    
    # get the forum information
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    # get all moderators
    $c->stash->{forum_roles} = $c->forward('/policy/get_forum_moderators', [ $forum_id ] );
    
    
    
    my @extra_cols = ('elite', 1) if ($is_elite);
    
    my $it = $c->model('DBIC')->resultset('Topic')->search( {
        forum_id => $forum_id,
        @extra_cols,
    }, {
        order_by => 'sticky DESC, last_update_date DESC',
        rows => $c->config->{per_page}->{forum},
        page => $page_no,
        prefetch => ['author', 'last_updator'],
    } );
    
    my @topics  = $it->all;
    # Pager
	my $pager = $it->pager;
	
	$c->stash->{topics} = \@topics;
	$c->stash->{pager} = $pager;
	$c->stash->{template} = 'forum/forum.html';
}

1;
