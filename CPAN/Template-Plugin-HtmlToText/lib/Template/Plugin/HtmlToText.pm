package Template::Plugin::HtmlToText;

use strict;
use vars qw( @ISA $VERSION );
use base qw( Template::Plugin );
use Template::Plugin;

$VERSION = '0.01';

sub new {
    my ($class, $context, $arg) = @_;
    $context->define_filter('html2text', [ \&html2text => 1 ]);
    return \&tt_wrap;
}

sub html2text {
    my ($context, $args) = @_;
    return sub {
        my $html = shift;
        return $html unless ($html =~ m#(<|>)#s);
        
        require HTML::TreeBuilder;
        my $tree = HTML::TreeBuilder->new->parse($html);
        require HTML::FormatText;
        my $formatter = HTML::FormatText->new(%{$args});
        my $text = $formatter->format($tree);
        return $text;
    }
}


1;

__END__

=head1 NAME

Template::Plugin::HtmlToText - Plugin interface to HTML::FormatText

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    [% USE HtmlToText %]

    # or use text2html FILTER
    [% myhtml FILTER html2text(leftmargin => 0, rightmargin => 50) %]

=head1 DESCRIPTION

This plugin provides an interface to the HTML::FormatText module which 
format HTML as plaintext.

=head1 AUTHOR

Fayland Lam, C<< <fayland> >>

=head1 COPYRIGHT & LICENSE

Copyright 2006 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Template::Plugin::HtmlToText
