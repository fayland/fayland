package Foorum::Controller::Site;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Foorum::Utils qw/get_page_from_url/;
use Data::Dumper;

sub recent : Local {
    my ($slef, $c, $recent_type) = @_;
    
    my @extra_cols;
    my $url_prefix;
    if ($recent_type eq 'elite') {
        @extra_cols = ('elite', 1);
        $url_prefix .= '/site/recent/elite';
    } else {
        $recent_type = 'site';
        $url_prefix = '/site/recent';
    }
    
    $c->cache_page( '300' );
    
    my $page = get_page_from_url($c->req->path);
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
        template => 'site/recent.html',
        topics   => [ $rs->all ],
        pager    => $rs->pager,
        recent_type => $recent_type,
        url_prefix  => $url_prefix,
    } );
}

sub online : Local {
    my ($self, $c, undef, $forum_code) = @_;

    $c->cache_page( '300' );

    my ($results, $pager) = $c->model('Online')->get_data($c, $forum_code);

    $c->stash( {
        results  => $results,
        pager    => $pager,
        template => 'site/online.html',
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
