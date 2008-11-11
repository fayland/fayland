package XML::HARef;

use warnings;
use strict;

our $VERSION = '0.01';

use vars qw/@EXPORT_OK @ISA/;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/
	ref_to_xml
/;

use Scalar::Util qw(reftype);
use XML::Writer;

sub ref_to_xml {
	my ( $ref, $xml ) = @_;
	
	my $writer = new XML::Writer( OUTPUT => \$xml, UNSAFE => 1 );
	
	_port_ref_to_xml_writer( \$writer, $ref );
	
	return $xml;
}

sub _port_ref_to_xml_writer {
	my ( $writer, $data, $val ) = @_;
	
	if ( reftype $data and reftype $data eq 'HASH' ) {
		my $attr = delete $data->{_attrs};
		my @keys = keys %$data;
		if ( scalar @keys == 1 ) {
			
			if ( defined $data->{ $keys[0] } ) {
				if ( scalar keys %$attr ) {
					$$writer->startTag( $keys[0], %$attr );
					_port_ref_to_xml_writer( $writer, $data->{ $keys[0] } );
					$$writer->endTag( $keys[0] );
				} else {
					_port_ref_to_xml_writer( $writer, $keys[0], $data->{ $keys[0] } );
				}
			} else {
				$$writer->emptyTag( $keys[0], %$attr );
			}

		} else {
			foreach my $key ( keys %$data ) {
				$$writer->startTag( $key, %$attr );
				_port_ref_to_xml_writer( $writer, $data->{$key} );
				$$writer->endTag( $key );
			}
		}
	} elsif ( reftype $data and reftype $data eq 'ARRAY' ) {
		foreach my $val ( @$data ) {
			_port_ref_to_xml_writer( $writer, $val );
		}
	} else {
		if ( $val ) {
			$$writer->dataElement( $data, $val );
		} else {
			$$writer->characters( $data );
		}
	}
}

1;
__END__

=head1 NAME

XML::HARef - XML and H(ash)A(rray)Ref

=head1 SYNOPSIS

    use XML::HARef qw/ref_to_xml/;
    
    my $xml = ref_to_xml( $data );

=head1 DESCRIPTION

Don't hate me!

=head1 SEE ALSO

L<XML::Writer>, L<XML::Quick>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
