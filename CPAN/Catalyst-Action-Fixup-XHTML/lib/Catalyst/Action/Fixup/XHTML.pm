package Catalyst::Action::Fixup::XHTML;

use warnings;
use strict;

our $VERSION = '0.01';

use base 'Catalyst::Action';

use HTTP::Negotiate qw(choose);

our $variants = [
    [qw| xhtml 1.000 application/xhtml+xml |],
    [qw| html  0.900 text/html             |],
];


sub execute {
    my $self = shift;
    my ($controller, $c ) = @_;
    $self->NEXT::execute( @_ );

    if ($c->request->header('Accept') && $c->response->headers->{'content-type'} =~ m|text/html|) {
        _pragmatic_accept($c);
        my $var = choose($variants, $c->request->headers);
        if ($var eq 'xhtml') {
            $c->response->headers->{'content-type'} =~ s|text/html|application/xhtml+xml|;
        }
    }
    return 1;
}

sub _pragmatic_accept {
    my ($c) = @_;
    my $accept = $c->request->header('Accept');
    if ($accept =~ m|text/html|) {
        $accept =~ s!\*/\*\s*([,]+|$)!*/*;q=0.5$1!;
    } else {
        $accept =~ s!\*/\*\s*([,]+|$)!text/html,*/*;q=0.5$1!;
    }
    $c->request->header('Accept' => $accept);
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

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Tomas Doran for the great L<Catalyst::View::TT::XHTML>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
