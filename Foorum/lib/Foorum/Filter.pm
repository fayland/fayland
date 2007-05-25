package Foorum::Filter;

use strict;
use warnings;
use base 'Exporter';
use vars qw/@EXPORT_OK $has_text_textile $has_ubb_code/;
@EXPORT_OK = qw/
    filter
    filter_format
    filter_bad_words
/;
$has_text_textile = eval "use Text::Textile; 1;";
$has_ubb_code = eval "use HTML::BBCode; 1;";

sub filter {
    my ($text, $params) = @_;
    
    if ($params->{format}) {
        $text = filter_format($text, $params);
    }
}

sub filter_format {
    my ($text, $params) = @_;
    
    my $format = $params->{format};
    if ($format eq 'textile' and $has_text_textile) {
		my $formatter = Text::Textile->new();
		$formatter->charset('utf-8');
		$text = $formatter->process( $text );
    } elsif (($format eq 'ubb' or $format eq 'default') and $has_ubb_code) {
        my $formatter = HTML::BBCode->new( {
            no_html      => 1,
            no_jslink    => 1,
            linebreaks   => 1,
        } );
        $text = $formatter->parse( $text );
    }
    
    return $text;
}

sub filter_bad_words {
    my ($text, $params) = @_;

}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;