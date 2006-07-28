package Text::Formatter::Fayland;

# IT"S ABANDONED!!
#  NO MORE USE FOR MEMORY LEAK!
#

#use strict;
use base qw(Exporter);
use vars qw(@EXPORT_OK $VERSION);
use Exporter;
@EXPORT_OK = qw(process);
$VERSION = 0.01;

use Perl6::Rules;

sub new {
    my $class = shift;
    return bless { }, $class;
}

sub process {
	my ($self, $text) = @_;
	
	study($text);

	# \r
	$text =~ s:g/\r//;
	
	# <code></code>
	while ($text =~ m/\<code\>(.+?)\<\/code\>/) {
		my $_after = $1;
		# unHTML
		$_after =~ s:g{\&}{\&amp\;};
		$_after =~ s:g{\<}{\&lt\;};
		$text =~ s{\<code\>(.+?)\</code\>}{\<pre\>$_after\</pre\>};
	}

	# \t
	$text =~ s:g/\t/ \&nbsp; \&nbsp;/;

	# mapping special words such as People
	my %mapping_word = (
		'chunzi' => 'blog.chunzi.org',
		'joe jiang' => 'www.livejournal.com/users/joe_jiang/',
		'cnhackTNT' => 'www.wanghui.org',
		'Catalyst'  => 'dev.catalyst.perl.org',
		'PerlChina' => 'www.perlchina.org',
		'Pugs' => 'www.pugscode.org',
		'TT'   => 'www.template-toolkit.org',
		'modperl'  => 'perl.apache.org'
	);
	# my/our/local $p; IS FAILED!
	# BE CAREFUL! must be $main::p!
	foreach $main::p (keys %mapping_word) {
		$text =~ s{\b$::p\b}{<a href="http://$mapping_word{$main::p}">$main::p</a>};
	}

	# [[http://www.fayland.org]]
	$text =~ s:g{\[\[((http|https|ftp)\://\S+)\]\]}{<a href="$1">$1</a>};
    
    # L<Module:Module>
    $text =~ s:g{(<ws>)L\<([\w|\:]+)\>(<ws>)}{$1<a href="http://search.cpan.org/perldoc\?$2">$2</a>$3};

	# = H1 == H2
	# YAP!! FAILED!!!
	#for my $n (1 .. 4) {
	#	$text =~ s:g{[^|\n]=<$::n><ws>(.+?)\n}{\<h$n>$1</h$n>};
	#}
	$text =~ s:g{[^|\n+]=<1><ws>(.+?)\n+}{\<h1>$1</h1>};
	$text =~ s:g{[^|\n+]=<2><ws>(.+?)\n+}{\<h2>$1</h2>};
	$text =~ s:g{[^|\n+]=<3><ws>(.+?)\n+}{\<h3>$1</h3>};
	$text =~ s:g{[^|\n+]=<4><ws>(.+?)\n+}{\<h4>$1</h4>};

	# for </li>
	$text =~ s:g{\<\/(li|ul|pre)\>\n+}{\<\/$1\>};
	
	# \n<1,>
	$text =~ s:g{\n<2,>}{\<p />};
	$text =~ s:g{\n<1>}{\<br />};
	
	return $text;
}

1;