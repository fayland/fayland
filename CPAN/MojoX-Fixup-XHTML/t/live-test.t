#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 4;

use Mojo::Client;
use Mojo::Transaction::Single;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestApp;

my $client = Mojo::Client->new;

my $tx = Mojo::Transaction::Single->new_get('/?html=1');
$client->process_app('TestApp', $tx);
is($tx->res->headers->content_type, 'text/html');

my $tx2 = Mojo::Transaction::Single->new_get('/');
$client->process_app('TestApp', $tx2);
is($tx2->res->headers->content_type, 'text/plain');

# it sould change text/html to application/xhtml+xml
# after we add Accpet 'application/xhtml+xml' header
my $tx3 = Mojo::Transaction::Single->new_get('/?html=1', {
    Accept => 'application/xhtml+xml'
} );
$client->process_app('TestApp', $tx3);
is($tx3->res->headers->content_type, 'application/xhtml+xml');

# but it shouldn't effect test/plain
my $tx4 = Mojo::Transaction::Single->new_get('/', {
    Accept => 'application/xhtml+xml'
} );
$client->process_app('TestApp', $tx4);
is($tx4->res->headers->content_type, 'text/plain');

1;