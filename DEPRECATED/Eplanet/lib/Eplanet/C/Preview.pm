package Eplanet::C::Preview;

use Data::Dumper;
use base 'Catalyst::Base';
#use encoding "euc-cn", STDOUT => "utf8";
#use Encode qw/from_to/;

sub preview : Global {
	my ( $self, $c, $submit ) = @_;
	
	my $text = $c->req->params->{'text'};
	my $form = $c->req->params->{'formatter'};
	# damn it, for support the win32, we need to s/\r/
	$text =~ s/\r//g;

	my $formatter;
	if ($form eq 'textile') {
		use Text::Textile;
		$formatter = Text::Textile->new();
		$formatter->charset('utf-8');
		
		$text = $formatter->process( $text );
	} elsif ($form eq 'kwiki') {
		use Text::KwikiFormatter;
		$formatter = Text::KwikiFormatter->new();
		
		$text = $formatter->process( $text );
	} elsif ($form eq 'fayland') {
		use Text::Formatter::Fayland;
		$formatter = Text::Formatter::Fayland->new();
		
		$text = $formatter->process( $text );
	} elsif ($form eq 'land') {
		use Text::Formatter::Land;
		$formatter = Text::Formatter::Land->new();
		
		$text = $formatter->process( $text );
	} else {
		# default
		$text =~ s/\r//g;
		# for <code>
		while ($text =~/\<code\>(.+?)\<\/code\>/is) {
			my $_temp = $1;
			$_temp =~ s/\</\&lt\;/sg;
			#$_temp =~ s/\>/\&gt\;/sg;
			$text =~ s/\<code\>(.+?)\<\/code\>/\&lt\;code\>$_temp\&lt\;\/code\>/is;
		}
		$text =~ s/\&lt\;(\/)?code\>/\<$1code\>/isg;
	}
	
	$c->res->output($text);

}

1;
