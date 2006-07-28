package Text::KwikiFormatter;

use strict;

use vars qw( $VERSION );
$VERSION = '0.01';

use base qw(CGI::Kwiki::Formatter);

sub new {
    my $class = shift;
    my $self = { @_ };
    bless $self, $class;
    return $self;
}

sub wiki_link_format {
    my ($self, $text) = @_;
    #my $wiki_link;
    #if ($text =~ /^[\w\d]+\:\:[\w\d\:]+$/) {
    #	$wiki_link = qq(<a href='http://search.cpan.org/perldoc?$text'>$text</a>);
    #} else {
    #	$wiki_link = qq{<a href='$text.html'>$text</a>};
    #}
    #return $wiki_link;
    return $text;
}


1;

=head1 NAME

Text::KwikiFormatter - A Kwiki formatter.

=head1 DESCRIPTION

=head1 SYNOPSIS
