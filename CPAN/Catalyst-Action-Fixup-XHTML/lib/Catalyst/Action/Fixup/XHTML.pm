package Catalyst::Action::Fixup::XHTML;

use warnings;
use strict;

our $VERSION = '0.03';

use base 'Catalyst::Action';
use HTTP::Negotiate qw(choose);
use MRO::Compat;

our $variants = [
    [qw| xhtml 1.000 application/xhtml+xml |],
    [qw| html  0.900 text/html             |],
];

sub execute {
    my $self = shift;
    my ($controller, $c ) = @_;
    $self->next::method(@_);

    if ( my $accept = _pragmatic_accept($c) && $c->response->headers->{'content-type'} &&
        $c->response->headers->{'content-type'} =~ m|text/html|) {
        my $headers = $c->request->headers->clone;
        $headers->header('Accept' => $accept);
        if ( choose($variants, $headers) eq 'xhtml') {
            $c->response->headers->{'content-type'} =~ s|text/html|application/xhtml+xml|;
        }
    }
    return 1;
}

sub _pragmatic_accept {
    my ($c) = @_;
    my $accept = $c->request->header('Accept') or return;
    if ($accept =~ m|text/html|) {
        $accept =~ s!\*/\*\s*([,]+|$)!*/*;q=0.5$1!;
    } 
    else {
        $accept =~ s!\*/\*\s*([,]+|$)!text/html,*/*;q=0.5$1!;
    }
    return $accept;
}

1;
__END__

=head1 NAME

Catalyst::Action::Fixup::XHTML - Catalyst action which serves application/xhtml+xml content if the browser accepts it.

=head1 SYNOPSIS

    sub end : ActionClass('Fixup::XHTML') {}

=head1 DESCRIPTION

Most of the code are copied from L<Catalyst::View::TT::XHTML>, please refer the doc there.

It's an action because I think it can be used in other views like Mason.

=head1 RenderView

Since Catalyst doesn't support two ActionClass attributes now, you need do follows to make them together.

    sub render : ActionClass('RenderView') { }
    sub end : ActionClass('Fixup::XHTML') {
        my ( $self, $c ) = @_;
        
        $c->forward('render');
    }

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Tomas Doran for the great L<Catalyst::View::TT::XHTML>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
