package Padre::Plugin::WordStats;

use warnings;
use strict;

our $VERSION = '0.01';

my @menu = (
    ['Word stats', \&count_word_stats ],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub count_word_stats {
	my ( $self ) = @_;
	
	my $code;
    my $src = $self->selected_text;
    my $doc = $self->selected_document;
    if ( $src ) {
        $code = $src;
    } else {
        $code = $doc->text_get;
    }
    
    
}

1;
__END__

=head1 NAME

Padre::Plugin::WordStats - Word stats for L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> WordStats -> Word stats

=head1 DESCRIPTION

Count how many chars, lines, chars without spaces within your L<Padre>

If there is any selection, just run with the text you selected.

If not, run with the selected whole document.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
