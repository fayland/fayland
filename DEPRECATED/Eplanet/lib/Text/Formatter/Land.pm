package Text::Formatter::Land;

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

sub new {
    my $class = shift;
    return bless { }, $class;
}

sub process {
	my ($self, $text) = @_;
	
	study($text);

	# \r
	$text =~ s/\r//sg;
	
	# <code></code>
	while ($text =~ /\<code\>(.+?)\<\/code\>/is) {
		my $_after = $1;
		# unHTML
		$_after =~ s/\&/\&amp\;/sg;
		$_after =~ s/\</\&lt\;/sg;
		$text =~ s/\<code\>(.+?)\<\/code\>/\<pre\>$_after\<\/pre\>/is;
	}

	# \t
	$text =~ s/\t/ \&nbsp; \&nbsp;/g;

	# mapping special words such as People
	my %mapping_word = (
		'chunzi'    => 'blog.chunzi.org',
		'joe jiang' => 'www.livejournal.com/users/joe_jiang/',
		'cnhackTNT' => 'www.wanghui.org',
		'Catalyst'  => 'dev.catalyst.perl.org',
		'PerlChina' => 'www.perlchina.org',
		'Pugs'      => 'www.pugscode.org',
		'TT'        => 'www.template-toolkit.org',
		'modperl'   => 'perl.apache.org',
		'ShellWeb'  => 'sourceforge.net/projects/shellweb',
	);

	foreach my $p (keys %mapping_word) {
		$text =~ s{\b$p\b}{<a href="http://$mapping_word{$p}">$p</a>};
	}

	# [[http://www.fayland.org]]
	$text =~ s{\[\[((http|https|ftp)\://\S+)\]\]}{<a href="$1">$1</a>}g;
    
    # L<Module:Module>
    $text =~ s{(\s+)L\<([\w|\:]+)\>(\s+)}{$1<a href="http://search.cpan.org/perldoc\?$2">$2</a>$3}g;

    # GG<comp.lang.perl.modules>
    $text =~ s{(\s+)GG\<([\w|\.]+)\>(\s+)}{$1<a href="http://groups.google.com/group/$2">$2</a>$3}g;

	# = H1 == H2
	$text =~ s{(^|\n+)={1}\s+(.+?)\n+}{\<h1>$2</h1>}g;
	$text =~ s{(^|\n+)={2}\s+(.+?)\n+}{\<h2>$2</h2>}g;
	$text =~ s{(^|\n+)={3}\s+(.+?)\n+}{\<h3>$2</h3>}g;
	$text =~ s{(^|\n+)={4}\s+(.+?)\n+}{\<h4>$2</h4>}g;

	# for </li>
	$text =~ s{\<\/(li|ul|pre|h1|h2|h3|h4)\>\n+}{\<\/$1\>}g;
	$text =~ s{\<(ul|pre)\>\n+}{\<$1\>}g;
	
	# \n<1,>
	$text =~ s{\n{2,}}{\<p />}g;
	$text =~ s{\n{1}}{\<br />}g;
	
	return $text;
}

1;