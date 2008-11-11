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

our $DEBUG = 1;

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
					warn "HASH with attrs and val\n" if $DEBUG;
					_port_ref_to_xml_writer( $writer, $data->{ $keys[0] } );
					$$writer->endTag( $keys[0] );
				} else {
					warn "HASH with no attrs and val\n" if $DEBUG;
					_port_ref_to_xml_writer( $writer, $keys[0], $data->{ $keys[0] } );
				}
			} else {
				warn "HASH with attrs and no val\n" if $DEBUG;
				$$writer->emptyTag( $keys[0], %$attr );
			}

		} else {
			foreach my $key ( keys %$data ) {
				$$writer->startTag( $key, %$attr );
				warn "HASH with attrs and many keys\n" if $DEBUG;
				_port_ref_to_xml_writer( $writer, $data->{$key} );
				$$writer->endTag( $key );
			}
		}
	} elsif ( reftype $data and reftype $data eq 'ARRAY' ) {
		foreach my $val ( @$data ) {
			warn "ARRAY\n" if $DEBUG;
			_port_ref_to_xml_writer( $writer, $val );
		}
	} else {
		if ( defined $val and reftype $val and ( reftype $val eq 'HASH' or reftype $val eq 'ARRAY' ) ) {
			$$writer->startTag( $data );
			warn "VAL reftype\n" if $DEBUG;
			_port_ref_to_xml_writer( $writer, $val );
			$$writer->endTag( $data );
		} else {
			if ( $val ) {
				$$writer->dataElement( $data, $val );
			} else {
				$$writer->characters( $data );
			}
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

I'm going to add "xml_to_ref" soon. so when you have a XML, we want a hashref/arrayref to create this XML.
you can just use "xml_to_ref" get the structure of REF, then create it, call xml_to_ref to get the final XML.

=head2 ref_to_xml

from ref to XML by L<XML::Writer>

It's doing something like L<XML::Quick> but it's not the same.

=head2 xml_to_ref

TODO

=head1 SEE ALSO

L<XML::Writer>, L<XML::Quick>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
