package Padre::Plugin::UpLowCase;

use warnings;
use strict;

our $VERSION = '0.01';

my @menu = (
    ['UC All', \&uc_all],
    ['LC All', \&lc_all],
    ['UC First', \&uc_first],
    ['LC First', \&lc_first],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub uc_all {
	_uc_lc_all_first( @_, 'uc_all' );
}
sub lc_all {
	_uc_lc_all_first( @_, 'lc_all' );
}
sub uc_first {
	_uc_lc_all_first( @_, 'uc_first' );
}
sub lc_first {
	_uc_lc_all_first( @_, 'lc_first' );
}

sub _uc_lc_all_first {
	my $self = shift;
	my $type = pop;
	
	my $code;
    my $src = $self->selected_text;
    my $doc = $self->selected_document;
    if ( $src ) {
        $code = $src;
    } else {
        $code = $doc->text_get;
    }
    
    return unless ( defined $code and length($code) );
    
    if ( $type eq 'uc_all' ) {
		$code = uc($code);
	} elsif ( $type eq 'lc_all' ) {
		$code = lc($code);
	} elsif ( $type eq 'uc_first' ) {
		$code =~ s/\b(\S+)\b/ucfirst($1)/ge;
	} elsif ( $type eq 'lc_first' ) {
		$code =~ s/\b(\S+)\b/lcfirst($1)/ge;
	}
    
    if ( $src ) {
		my $editor = $self->selected_editor;
	    $editor->ReplaceSelection( $code );
	} else {
		$doc->text_set( $code );
	}

}

1;
__END__

=head1 NAME

Padre::Plugin::UpLowCase - upper, lower, no big case

=head1 SYNOPSIS

	$>padre
	Plugins -> Encrypt -> 
						  UC All
						  LC All
						  UC First
						  LC First

=head1 DESCRIPTION

English Only for now.

=head2 UC All

	uc($word)

=head2 LC All

	lc($word)

=head2 UC First

	ucfirst($word)

=head2 LC First

	lcfirst($word)

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
