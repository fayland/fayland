package YAML::LoadURI;

use warnings;
use strict;

our $VERSION = '0.02';

use base 'Exporter';
our @EXPORT = ('LoadURI');

use LWP::Simple qw/$ua/;
use YAML::Any   ();
use Carp qw/croak/;

sub LoadURI {
    my ( $uri, $opts ) = @_;
    
    $opts->{raise_error} = 1 unless exists $opts->{raise_error};
    
    my $response = $ua->get($uri);
    if ( $response->is_success ) {
        my $yaml = $response->content;
        unless ( $yaml =~ /^---/ ) {
            croak "invalid YAML" if $opts->{raise_error};
            return;
        }
        return YAML::Any::Load($yaml);
    } else {
        croak "Couldn't get it!" if $opts->{raise_error};
        return;
    }    
}

1;
__END__

=head1 NAME

YAML::LoadURI - Load YAML from URI file

=head1 SYNOPSIS

    use YAML::LoadURI;
    my $hashref = LoadURI( $uri );

=head1 EXPORT

=head2 LoadURI( $uri, $opts )

    my $h  = LoadURI( 'http://search.cpan.org/dist/WWW-Contact/META.yml' );
    my $h2 = LoadURI( $uri, { raise_error => 0 } );

by default, it would croak when we can't get the file from remote. you can use { raise_error => 0 } to make it silence.

=head1 SEE ALSO

L<YAML::Any>, L<LWP::Simple>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
