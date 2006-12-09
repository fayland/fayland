package Foorum::Controller::RSS;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use XML::RSS;
use Date::Manip;

sub forum : Regex('^forum/(\d+)/rss$') {
    my ($self, $c) = @_;
    
    $c->cache_page( '600' );
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->model('DBIC::Forum')->find( {
        forum_id => $forum_id,
    }, {
        columns => ['policy', 'name', 'description'],
    } );
    return unless ($forum);
    return if ($forum->policy eq 'private');
    
    my @topics = $c->model('DBIC')->resultset('Topic')->search( {
        forum_id => $forum_id,
    }, {
        order_by => 'last_update_date DESC',
        rows => 20,
        page => 1,
    } )->all;
    
    my $forum_url = $c->req->base . 'forum/' . $forum_id;
    my $rss = new XML::RSS (version => '2.0');
    $rss->channel(
        title          => $forum->name,
        link           => $forum_url,
        description    => $forum->description,
        pubDate        => UnixDate ("today", "%Y-%m-%dT%H:%M:%S+00:00"),
        lastBuildDate  => UnixDate ("today", "%Y-%m-%dT%H:%M:%S+00:00"),
        generator      => 'Foorum',
    );
    
    foreach (@topics) {
        my $pubDate = $_->last_update_date;
        $pubDate =~ s/\s+/T/;
        
        my $rs = $c->model('DBIC::Comment')->find( {
            object_type => 'thread',
            object_id   => $_->topic_id,
        }, {
            order_by => 'post_on',
            rows => 1, page => 1,
        } );
        next unless ($rs);
        
        my $topic_url = $forum_url . '/' . $_->topic_id;
        $rss->add_item(
            title       => $_->title,
            link        => $topic_url,
            description => $rs->text,
            pubDate     => $pubDate,	
            permaLink   => $topic_url,
        );
    }
    
    $c->res->body($rss->as_string);
}

sub end : Private {
    my ($self, $c) = @_;
    
    return if ($c->res->body);
    $c->res->body(<<'RSS');
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
<title>ERROR</title>
</channel>
</rss>
RSS
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
