package TestApp;

use strict;
use warnings;

our $VERSION = '0.01';

use base 'Mojolicious';

use File::Spec;
use MojoX::Fixup::XHTML;

# This method will run for each request
sub dispatch {
    my ($self, $c) = @_;

    my $html = $c->req->params->to_hash->{html};
    if ( $html ) {
    	$c->res->headers->content_type('text/html');
		$c->res->body('1');	
	} else {
		$c->res->headers->content_type('text/plain');
		$c->res->body('2');
	}
    
    MojoX::Fixup::XHTML->fix_xhtml( $c );
}

# This method will run once at server start
sub startup {
    my $self = shift;
    
    # no log
    $self->log->path( File::Spec->tmpdir() . '/' . $$ . '.log' );
}

1;
