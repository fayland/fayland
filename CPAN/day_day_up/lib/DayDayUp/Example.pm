package DayDayUp::Example;

use strict;
use warnings;

use base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
    my ($self, $c) = @_;

    # Render template "example/welcome.phtml"
    $c->render;
}

1;
