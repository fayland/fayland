package DayDayUp;

use strict;
use warnings;

our $VERSION = '0.06';

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

    # route
    $r->route('/notes/:id/:action', id => qr/\d+/)
      ->to(controller => 'notes', action => 'index');
    $r->route('/contacts/:id/:action', id => qr/\d+/)
      ->to(controller => 'contacts', action => 'index');
    # Default route
    $r->route('/:controller/:action')
      ->to(controller => 'index', action => 'index');
}

1;
__END__

=head1 NAME

DayDayUp - good good study, day day up

=head1 DESCRIPTION

it's just a test with L<Mojo>

but I don't mind if you use it in your localhost.

=head1 RUN

	perl bin/day_day_up daemon

=head1 CONFIGURATION

create a daydayup_local.yml at the same dir as daydayup.yml

=head1 SEE ALSO

L<Mojo>, L<Mojolicious>

=head1 AUTHOR

Fayland Lam < fayland at gmail dot com >

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
