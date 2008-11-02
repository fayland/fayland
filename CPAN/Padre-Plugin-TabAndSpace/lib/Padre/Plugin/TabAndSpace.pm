package Padre::Plugin::TabAndSpace;

use warnings;
use strict;

our $VERSION = '0.01';

use Wx ':everything';
use Padre::Wx::History::TextDialog;

my @menu = (
    ['Tab to Space', \&tab_to_space ],
    ['Space to Tab', \&space_to_tab ],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub tab_to_space {
    _convert_tab_with_space($_[0], 'Tab_to_Space');
}

sub space_to_tab {
    _convert_tab_with_space($_[0], 'Space_to_Tab');
}

sub _convert_tab_with_space {
    my ( $self, $type ) = @_;
    
    my ( $title, $conte );
    if ( $type eq 'Space_to_Tab' ) {
        $title = 'Space to Tab';
    } else {
        $title = 'Tab to Space';
    }
    
    my $dialog = Padre::Wx::History::TextDialog->new(
        $self, 'How many spaces for each tab:', $title, 'OK',
    );
    if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
        return;
    }
    my $space_num = $dialog->GetValue;
    $dialog->Destroy;
    unless ( defined $space_num and $space_num =~ /^\d+$/ ) {
        return;
    }
    
    my $code;
    my $src = $self->selected_text;
    my $doc = $self->selected_document;
    if ( $src ) {
        $code = $src;
    } else {
        $code = $doc->text_get;
    }
    
    return unless ( defined $doc and length($doc) );
    
    my $to_space = ' ' x $space_num;
    if ( $type eq 'Space_to_Tab' ) {
        $code =~ s/$to_space/\t/isg;
    } else {
        $code =~ s/\t/$to_space/isg;
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

Padre::Plugin::TabAndSpace - convert between space and tab within L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> TabAndSpace -> 
                              Tab to Space
                              Space to Tab

=head1 DESCRIPTION

This is a simple plugin to "convert tabs to spaces" or "convert spaces to tabs".

If there is any selection, just run with the text you selected.

If not, run with the selected whole document.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
