package CatalystX::Foorum;

use warnings;
use strict;
use version;
use vars qw/$VERSION/;

$VERSION = version->new("0.1.1");

1;
__END__

=head1 NAME

CatalystX::Foorum - Forum/BBS system based on Catalyst

=head1 VERSION

Version 0.1.0

=head1 DESCRIPTION

It's just a placeholder for the project Foorum. L<http://code.google.com/p/foorum/>

=head1 DOWNLOAD

L<http://foorum.googlecode.com/files/Foorum-0.1.1.tar.gz>

=head1 LIVE DEMO

L<http://www.foorumbbs.com/>

=head1 FEATURES

=over 4

=item open source

u can FETCH all code from L<http://foorum.googlecode.com/svn/trunk/> any time any where.

=item Win32 compatibility

Linux/Unix/Win32 both OK.

=item templates

use L<Template> for UI.

=item built-in cache

use L<Cache::Memcached> or use L<Cache::FileCache> or others;

=item reliable job queue

use L<TheSchwartz>

=item Multi Formatter

L<HTML::BBCode>, L<Text::Textile>, L<Pod::Xhtml>, L<Text::GooglewikiFormat>

=item Captcha

To keep robot out.

=back

=head1 JOIN US

please send me an email to add u into the google.code Project members list.

=head1 TODO

L<http://code.google.com/p/foorum/issues/list>

=head1 SEE ALSO

L<Catalyst::Runtime>, L<DBIx::Class>, L<Template>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
