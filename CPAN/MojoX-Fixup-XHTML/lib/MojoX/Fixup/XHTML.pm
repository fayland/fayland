package MojoX::Fixup::XHTML;

use warnings;
use strict;

use base 'Mojo::Base';

our $VERSION = '0.04';

use HTTP::Headers;
use HTTP::Negotiate qw(choose);

our $variants = [
    [qw| xhtml 1.000 application/xhtml+xml |],
    [qw| html  0.001 text/html             |],
];

sub fix_xhtml {
    my ( $self, $c ) = @_;

    if ( $c->req->headers->header('Accept') && $c->res->headers->content_type &&
         $c->res->headers->content_type =~ m|text/html|) {
    	my $accept = $c->req->headers->header('Accept');
		if ($accept =~ m|text/html|) {
			$accept =~ s!\*/\*\s*([,]+|$)!*/*;q=0.5$1!;
		} else {
			$accept =~ s!\*/\*\s*([,]+|$)!text/html,*/*;q=0.5$1!;
		}
		$c->req->headers->header('Accept', $accept);
        my $var = choose($variants, HTTP::Headers->new(%{$c->req->headers->{_headers}}));
        if ($var eq 'xhtml') {
            my $content_type = $c->res->headers->content_type;
            $content_type =~ s|text/html|application/xhtml+xml|;
            $c->res->headers->content_type($content_type);
        }
    }
    
    return 1;
}

1;
__END__

=head1 NAME

MojoX::Fixup::XHTML - serves application/xhtml+xml content for L<Mojo>

=head1 SYNOPSIS

    package MyApp;
    
    use base 'Mojolicious';
    use MojoX::Fixup::XHTML;

    sub dispatch {
        my ($self, $c) = @_;

        # Try to find a static file
        my $done = $self->static->dispatch($c);

        # Use routes if we don't have a response code yet
        unless ( $done ) {
            $done = $self->routes->dispatch($c);
            if ( $done ) {
                MojoX::Fixup::XHTML->fix_xhtml( $c );
            }
        }

        # Nothing found, serve static file "public/404.html"
        unless ($done) {
            $self->static->serve($c, '/404.html');
            $c->res->code(404);
        }
    }

=head1 DESCRIPTION

This sets the response C<Content-Type> to be C<application/xhtml+xml> if the
user's browser sends an C<Accept> header indicating that it is willing
to process that MIME type.

Changing the C<Content-Type> causes browsers to interpret the page as
strict XHTML, meaning that the markup must be well formed.

This is useful when you're developing your application, as you know that
all pages you view are rendered strictly, so any markup errors will show
up at once.

=head1 ACKNOWLEDGEMENTS

Tomas Doran - L<Catalyst::View::TT::XHTML>, most of the code are copied from there

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
