package
    TestApp;

use strict;
use warnings;

our $VERSION = '0.01';

use base 'Mojolicious';

use File::Spec;
use MojoX::Fixup::XHTML;
use MRO::Compat;

# This method will run for each request
sub dispatch {
    my ($self, $c) = @_;

    $self->next::method($c);

    MojoX::Fixup::XHTML->fix_xhtml( $c );
}

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->log->path( File::Spec->tmpdir() . '/' . $$ . '.log' );

    # Routes
    my $r = $self->routes;

    # Default route
    $r->route('/:controller/:action/:id')
      ->to(controller => 'example', action => 'welcome', id => 1);
}

package
    TestApp::Example;

use strict;
use warnings;

use base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
    my $self = shift;

    my $html = $self->req->params->to_hash->{html} || 0;
    if ( $html ) {
    	$self->res->headers->content_type('text/html');
		$self->render_text('1');	
	} else {
		$self->res->headers->content_type('text/plain');
		$self->render_text('2');
	}
}

1;

1;
