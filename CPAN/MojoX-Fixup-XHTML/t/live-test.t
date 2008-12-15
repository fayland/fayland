#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 4;

use Mojo::Client;
use Mojo::Transaction;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestApp;

my $client = Mojo::Client->new;

my $tx     = Mojo::Transaction->new_get('/?html=1');
$client->process_local('TestApp', $tx);
is($tx->res->headers->content_type, 'text/html');

my $tx2 = Mojo::Transaction->new_get('/');
$client->process_local('TestApp', $tx2);
is($tx2->res->headers->content_type, 'text/plain');

# it sould change text/html to application/xhtml+xml
# after we add Accpet 'application/xhtml+xml' header
$tx->req->headers->header( Accept => 'application/xhtml+xml' );
$client->process_local('TestApp', $tx);
is($tx->res->headers->content_type, 'application/xhtml+xml');

# but it shouldn't effect test/plain
$tx2->req->headers->header( Accept => 'application/xhtml+xml' );
$client->process_local('TestApp', $tx2);
is($tx2->res->headers->content_type, 'text/plain');

1;