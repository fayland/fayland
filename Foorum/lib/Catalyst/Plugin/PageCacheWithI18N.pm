package Catalyst::Plugin::PageCacheWithI18N;

use strict;
use warnings;
use Class::C3;
use vars qw/$VERSION/;
$VERSION = '0.01';
use base qw/Catalyst::Plugin::PageCache/;

sub _get_page_cache_key {
    my ($c) = @_;
    
    my $key = $c->next::method(@_);
    my $lang = $c->req->cookie('pref_lang')->value if ($c->req->cookie('pref_lang'));
    $lang ||= $c->user->lang if ($c->user_exists);
    $lang ||= $c->config->{default_pref_lang};
    if (my $lang = $c->req->param('set_lang')) {
        $lang =~ s/\W+//isg;
        if (length($lang) == 2) {
            $lang = $lang;
        }
    }
    $key .= '#' . $lang if ($lang);
    return $key;
}

1;
