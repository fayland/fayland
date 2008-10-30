use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'CatalystX::Example::OpenID' }

ok( request('/')->is_success, 'Request should succeed' );
