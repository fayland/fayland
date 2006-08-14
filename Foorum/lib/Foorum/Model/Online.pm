package Foorum::Model::Online;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

use vars qw/$last_15_min/;
# get the last 15 minites' data
# 15 * 60 = 900
$last_15_min = time() - 900;

sub get_data {
    my ($self, $c, $forum_id, $attr) = @_;
    
    $attr->{page} = 1 unless ($attr->{page});
    $attr->{order_by} = 'expires' unless($attr->{order_by});
    
    my @extra_cols; 
    if ($forum_id) {
        @extra_cols = ( -or => [
            'path' => { 'like', "forum/$forum_id/%" },
            'path' => { 'like', "forum/$forum_id" },
            'path' => { 'like', "forumadmin/$forum_id/%" },
            'path' => { 'like', "forumadmin/$forum_id" },
        ] );
    }

    my $rs = $c->model('DBIC::Session')->search( {
        expires =>  { '>', $last_15_min }, 
        @extra_cols,
    }, {
        order_by => $attr->{order_by},
        rows     => 20,
        page     => $attr->{page},
    } ); 
    my @session = $rs->all;
    
    my @results = &_handler_session($self, $c, @session);
     
    return wantarray?(\@results, $rs->pager):\@results;
}

sub whos_view_this_page {
    my ($self, $c) = @_;
    
    my @session = $c->model('DBIC::Session')->search( {
        expires =>  { '>', $last_15_min },
        path    => $c->req->path,
    }, {
        order_by => 'expires',
        rows     => 20,
        page     => 1,
    } )->all; 

    my @results = &_handler_session($self, $c, @session);
    
    return wantarray?@results:\@results;
}

sub _handler_session {
    my ($self, $c, @session) = @_;
    
    my @results;
    foreach my $session (@session) {
       my $data = $c->get_session_data($session->id);
       my $refer = $data->{url_referer};
       my $visit_time  = $data->{__created};
       my $active_time = $data->{__updated};
       my $IP          = $data->{__address};
       my $user;
       $user = $c->model('DBIC::User')->find( { user_id => $session->user_id } ) if ($session->user_id);
       push @results, { user => $user, refer => $refer, visit_time => $visit_time, active_time => $active_time, IP => $IP };
    }
    
    return wantarray?@results:\@results;
}

1;
