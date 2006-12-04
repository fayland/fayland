package Catalyst::Plugin::SkipDotSVNURL;

use strict;
use warnings;
use NEXT;
use vars qw/$VERSION/;
$VERSION = '0.01';

sub dispatch {
    my $c = shift;
    
    if ($c->req->path =~ /(^|\/)\.svn(\/|$)/) {
        $c->res->status(404);
        $c->res->body('Forbidden');
        return;
    }

    return $c->NEXT::ACTUAL::dispatch(@_);
}

1;
