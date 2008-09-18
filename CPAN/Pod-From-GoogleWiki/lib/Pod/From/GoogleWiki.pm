package Pod::From::GoogleWiki;

use warnings;
use strict;
use vars qw/$VERSION/;
$VERSION = '0.01';

use Moose;


1;
__END__

=head1 NAME

Pod::From::GoogleWiki - convert from Google Code wiki markup to POD

=head1 SYNOPSIS

    use Pod::From::GoogleWiki;

    my $pfg = Pod::From::GoogleWiki->new();
    ...



=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Thanks to schwern: L<http://use.perl.org/~schwern/journal/37476>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
