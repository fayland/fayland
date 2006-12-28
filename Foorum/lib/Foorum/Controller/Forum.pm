package Foorum::Controller::Forum;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Foorum::Utils qw/get_page_no_from_url/;
use Data::Dumper;

sub board : Path {
    my ($self, $c) = @_;

    my @forums = $c->model('DBIC')->resultset('Forum')->search( { }, {
        order_by => 'me.forum_id',
        prefetch => ['last_post'],
    } )->all;

    $c->cache_page( '300' ) unless ($c->user_exists);

    # get all moderators
    my @forum_ids;
    push @forum_ids, $_->forum_id foreach (@forums);
    my $roles = $c->model('Policy')->get_forum_moderators( $c, \@forum_ids );
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
    $c->stash->{forum_roles} = $c->model('Policy')->get_forum_moderators( $c, $forum_id );


    # for page 1 and normal mode
    if ($page_no == 1 and not $is_elite) {
        # poll
        my @polls = $c->model('DBIC')->resultset('Poll')->search( {
            forum_id => $forum_id,
            duration => { '>', time() },
        }, {
            order_by => 'time desc',
            prefetch => ['author'],
        } )->all;
        $c->stash->{polls} = \@polls;
        # for private forum
        if ($forum->policy eq 'private') {
            my $pending_count = $c->model('DBIC::UserRole')->count( {
                field => $forum_id,
                role  => 'pending',
            } );
            $c->stash( {
                pending_count => $pending_count,
            } );
        }
        # check announcement
        my $ann_cookie = $c->req->cookie("ann_$forum_id");
        unless ($ann_cookie and $ann_cookie->value) {
            $c->stash->{announcement} = $c->model('DBIC::Comment')->find( {
                object_type => 'announcement',
                object_id   => $forum_id,
            }, {
                columns => ['title', 'text'],
            } );
            $c->res->cookies->{"ann_$forum_id"} = { value => 1 };
        }
    }

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
    if ($c->user_exists) {
        my @all_topic_ids = map { $_->topic_id } @topics;
        $c->stash->{is_visited} = $c->model('Visit')->is_visited($c, 'thread', \@all_topic_ids) if (scalar @all_topic_ids);
    }
    # Pager
    my $pager = $it->pager;

    $c->stash->{topics} = \@topics;
    $c->stash->{pager} = $pager;
    $c->stash->{template} = 'forum/forum.html';
}

sub members : LocalRegex('^(\d+)/members(/(\w+))?(/page=(\d+))?$') {
    my ($self, $c) = @_;

    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    my $member_type = $c->req->snippets->[2] || 'all';
    if ($member_type ne 'pending' and $member_type ne 'blocked' and $member_type ne 'rejected') {
        $member_type = 'user';
    }
    
    my $page_no  = $c->req->snippets->[4];
    $page_no = 1 unless ($page_no and $page_no =~ /^\d+$/);
    
    my (@query_cols, @attr_cols);
    if ($member_type eq 'user') {
        @query_cols = ('role', ['admin', 'moderator', 'user']);
        @attr_cols  = ('order_by' => 'role ASC');
    } else {
        @query_cols = ('role', $member_type);
    }
    my $rs = $c->model('DBIC::UserRole')->search( {
        @query_cols,
        field => $forum_id,
    }, {
        @attr_cols,
        rows => 20,
        page => $page_no,
    } );
    my @user_roles = $rs->all;
    my @all_user_ids = map { $_->user_id } @user_roles;
    
    my @members;
    my %members;
    if (scalar @all_user_ids) {
        @members = $c->model('DBIC::User')->search( {
            user_id => { 'IN', \@all_user_ids },
        }, {
            columns => ['user_id', 'username', 'nickname', 'gender', 'register_on'],
        } )->all;
        %members = map { $_->user_id => $_ } @members;
    }
 
    $c->stash( {
        template => 'forum/members.html',
        member_type => $member_type,
        pager => $rs->pager,
        user_roles => \@user_roles,
        members    => \%members,
    } );
}

sub join_us : Private {
    my ($self, $c, $forum_id) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    if ($c->req->method eq 'POST') {
        my $rs = $c->model('DBIC::UserRole')->find( {
            user_id => $c->user->user_id,
            field   => $forum_id,
        }, {
            columns => ['role'],
        } );
        if ($rs) {
            if ($rs->role eq 'user' or $rs->role eq 'moderator' or $rs->role eq 'admin') {
                return $c->res->redirect("/forum/$forum_id");
            } elsif ($rs->role eq 'blocked' or $rs->role eq 'pending' or $rs->role eq 'rejected') {
                my $role = uc($rs->role);
                $c->detach('/print_error', [ "ERROR_USER_$role" ]);
            }
        } else {
            $c->model('DBIC::UserRole')->create( {
                user_id => $c->user->user_id,
                field   => $forum_id,
                role    => 'pending',
            } );
            $c->detach('/print_message', [ 'Successfully Request. You need wait for admin\'s approval' ]);
        }
    } else {
        $c->stash( {
            simple_wrapper => 1,
            template => 'forum/join_us.html',
        } );
    }
}

sub recent : Local {
    my ($slef, $c, $recent_type) = @_;
    
    my @extra_cols;
    my $url_prefix = '/forum/recent';
    if ($recent_type eq 'elite') {
        @extra_cols = ('elite', 1);
        $url_prefix .= '/elite'
    }
    
    $c->cache_page( '300' ) unless ($c->user_exists);
    
    my $page = get_page_no_from_url($c->req->path);
    my $rs = $c->model('DBIC::Topic')->search( {
        'forum.policy' => 'public',
        @extra_cols,
    }, {
        order_by => 'last_update_date desc',
        prefetch => ['author', 'last_updator', 'forum'],
        join => [qw/forum/],
        rows => 20,
        page => $page,
    } );

    $c->stash( {
        template => 'forum/recent.html',
        topics   => [ $rs->all ],
        pager    => $rs->pager,
        recent_type => $recent_type,
        url_prefix  => $url_prefix,
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
