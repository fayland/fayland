package Pod::From::GoogleWiki;

use warnings;
use strict;
use vars qw/$VERSION/;
$VERSION = '0.01';

use Moose;

has 'tags' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub {
        {
            indent      => qr/^\s{1,}/,
            newline     => "\n\n",
            strong		=> sub { "<B>$_[0]</B>" },
        	italic      => sub { "<I>$_[0]</I> " },
        	strike   	=> sub { "<C>--$_[0]--</C>" },
        	superscript => sub { "($_[0])" },
        	subscript   => sub { "($_[0])" },
        	inline      => sub { "<C>$_[0]</C>" },
        	strong_tag  => qr/\*(.+?)\*/,
        	italic_tag  => qr/_(.+?)_/,
        	strike_tag  => qr/\~\~(.+?)\~\~/,
        	superscript_tag => qr/\^(.+?)\^/,
        	subscript_tag   => qr/\,\,(.+?)\,\,/,
        	inline_tag  => qr/\`(.+?)\`/,
        
            header      => [ '', '', sub {
        		my $level = length $_[2];
        		return "=head$level ", format_line($_[3], @_[-2, -1])
            } ],
        }
    }
);

sub pod2wiki {
    my ($self, $text) = @_;
    
    
}

1;
__END__

=head1 NAME

Pod::From::GoogleWiki - convert from Google Code wiki markup to POD

=head1 SYNOPSIS

    use Pod::From::GoogleWiki;

    my $pfg = Pod::From::GoogleWiki->new();
    my $wiki = read_from_file('wiki/Help.wiki');
    my $pod  = $pfg->wiki2pod($wiki);

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Thanks to schwern: L<http://use.perl.org/~schwern/journal/37476>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
