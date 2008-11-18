package DayDayUp::Index;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub index {
    my ($self, $c) = @_;

    $c->render(template => 'index/index.html' );
}

1;
