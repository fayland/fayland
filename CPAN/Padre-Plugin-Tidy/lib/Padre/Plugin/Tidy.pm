package Padre::Plugin::Tidy;

use warnings;
use strict;

our $VERSION = '0.01';

my @menu = (
    ['Tidy HTML', \&tidy_html],
    ['Tidy XML',  \&tidy_xml],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub tidy_html {
	my ( $self ) = @_;
	
	my $src = $self->selected_text;
	my $doc = $self->selected_document;
	my $code = ( $src ) ? $src : $doc->text_get;
	
	return unless ( defined $code and length($code) );
	
	require HTML::Tidy;
	my $tidy = HTML::Tidy->new;

	{
		no warnings;
		$tidy->parse( $0, $code );
	}

	my $text;
    for my $message ( $tidy->messages ) {
        $text .= $message->as_string . "\n";
    }
    
    $text = 'OK' unless ( length($text) );
	$self->show_output;
	$self->{output}->clear;
	$self->{output}->AppendText($text);
}

sub tidy_xml {
	my ( $self ) = @_;
	
	my $src = $self->selected_text;
	my $doc = $self->selected_document;
	my $code = ( $src ) ? $src : $doc->text_get;
	
	return unless ( defined $code and length($code) );
	
	require XML::Tidy;
	my $tidy_obj = XML::Tidy->new( xml => $code );
	$tidy_obj->tidy();
	
	my $string = $tidy_obj->toString();
	if ( $src ) {
		my $editor = $self->selected_editor;
	    $editor->ReplaceSelection( $string );
	} else {
		$doc->text_set( $string );
	}
}

1;
__END__

=head1 NAME

Padre::Plugin::Tidy - tidy html/xml in Padre

=head1 SYNOPSIS

	$>padre
	Plugins -> Encrypt -> 
						  Tidy HTML
						  Tidy XML

=head1 DESCRIPTION

tidy html/xml

if you are looking for PerlTidy, please check L<Padre::Plugin::PerlTidy>

=head2 Tidy HTML

Tidy HTML by L<HTML::Tidy>

=head2 Tidy XML

Tidy XML by L<XML::Tidy>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
