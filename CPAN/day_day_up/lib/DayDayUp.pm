package DayDayUp;

use strict;
use warnings;

use base 'Mojolicious';

# This method will run for each request
sub dispatch {
    my ($self, $c) = @_;

    # Try to find a static file
    my $done = $self->static->dispatch($c);

    # Use routes if we don't have a response code yet
    $done = $self->routes->dispatch($c) unless $done;

    # Nothing found, serve static file "public/404.html"
    unless ($done) {
        $self->static->serve($c, '/404.html');
        $c->res->code(404);
    }
}

# This method will run once at server start
sub startup {
    my $self = shift;

    # Use our own context class
    $self->ctx_class('DayDayUp::Context');

    # Routes
    my $r = $self->routes;

    # Default route
    $r->route('/:controller/:action/:id')
      ->to(controller => 'example', action => 'welcome', id => 1);
}

1;
