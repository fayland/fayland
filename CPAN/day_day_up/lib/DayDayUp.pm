package DayDayUp;

use strict;
use warnings;

our $VERSION = '0.01';

use base 'Mojolicious';

use MojoX::Renderer::TT;
use Template::Stash::XS;

use Data::Dumper;

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
      ->to(controller => 'index', action => 'welcome', id => 1);

	my $tt = MojoX::Renderer::TT->build(
		mojo => $self,
		template_options => {
			POST_CHOMP => 1,
			PRE_CHOMP  => 1,
			STASH      => Template::Stash::XS->new,
			INCLUDE_PATH => [ $self->home->rel_dir('templates') ],
			
        }
	);
	$self->renderer->add_handler( html => $tt );

}

1;
