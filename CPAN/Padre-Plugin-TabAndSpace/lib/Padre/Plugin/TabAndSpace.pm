package Padre::Plugin::TabAndSpace;

use warnings;
use strict;

our $VERSION = '0.05';

use Wx ':everything';
use Padre::Wx::History::TextDialog;

my @menu = (
    ['Tab to Space', \&tab_to_space ],
    ['Space to Tab', \&space_to_tab ],
    ['Delete Ending Space',  \&delete_ending_space ],
    ['Delete Leading Space', \&delete_leading_space ],
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
        $self, 'How many spaces for each tab:', $title, $type,
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

sub delete_ending_space {
    my ( $self ) = @_;
    
    my $code;
    my $src = $self->selected_text;
    my $doc = $self->selected_document;
    if ( $src ) {
        $code = $src;
    } else {
        $code = $doc->text_get;
    }
    
    # remove ending space
    $code =~ s/([^\n\S]+)$//mg;
    
    if ( $src ) {
        my $editor = $self->selected_editor;
        $editor->ReplaceSelection( $code );
    } else {
        $doc->text_set( $code );
    }
}

sub delete_leading_space {
    my ( $self ) = @_;

    my $src = $self->selected_text;
    unless ( $src ) {
        $self->message('No selection');
    }
    
    my $dialog = Padre::Wx::History::TextDialog->new(
        $self, 'How many leading spaces to delete(1 tab == 4 spaces):',
        'Delete Leading Space', 'fay_delete_leading_space',
    );
    if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
        return;
    }
    my $space_num = $dialog->GetValue;
    $dialog->Destroy;
    unless ( defined $space_num and $space_num =~ /^\d+$/ ) {
        return;
    }

    my $code = $src;
    my $spaces = ' ' x $space_num;
    my $tab_num = int($space_num/4);
    my $space_num_left = $space_num - 4 * $tab_num;
    my $tabs   = "\t" x $tab_num;
    $tabs .= '' x $space_num_left if ( $space_num_left );
    $code =~ s/^($spaces|$tabs)//mg;
    
    my $editor = $self->selected_editor;
    $editor->ReplaceSelection( $code );
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
                              Delete Ending Space
                              Delete Leading Space

=head1 DESCRIPTION

If there is any selection, just run with the text you selected.

If not, run with the selected whole document.

=head2 Tab to Space

convert 1 tab to $num spaces

=head2 Space to Tab

convert $num spaces to 1 tab

=head2 Delete Ending Space

delete ending space

=head2 Delete Leading Space

delete leading space with $num spaces. "selected" ONLY.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
