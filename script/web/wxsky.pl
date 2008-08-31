#!/usr/bin/perl

#######################################################################
#
# scrapbook doesn't run js inside the scrapped pages.
# so when scrapped pages use a js to include an image
# it wouldn't download that image
# that's the things in wxsky.net
# so that's what this script for.
# example:
# perl wxsky.pl http://www.wxsky.net/bookfiles/booklist3836.htm
#
#######################################################################

use strict;
use warnings;
use WWW::Mechanize;
use HTML::TokeParser::Simple;

my $url = shift;

my $book_id;
if ($url =~ /bookfiles\/booklist(\d+)\.htm/) {
    $book_id = $1;
}
$book_id or die "please provide a correct wxsky URL";

# prepare the dir
unless (-d "wxsky$book_id") {
    mkdir "wxsky$book_id", 0777;
}

my $ua = new WWW::Mechanize;
$ua->get("http://www.wxsky.net/bookfiles/booklist$book_id.htm");
my $content = $ua->content;

my @urls = parse_booklist($book_id, $content);

my $i = 0;
foreach my $a (@urls) {
    my $next_a = $urls[$i+1];
    my $next_chapter_id = ($next_a) ? $next_a->{chapter_id} : 0;
    parse_chapter($ua, $a->{chapter_id}, $a->{url}, $next_chapter_id);
    $i++;
}

sub parse_booklist {
    my ($book_id, $content) = @_;
    
    my @urls;
    my $p = HTML::TokeParser::Simple->new( string => $content );
    while ( my $token = $p->get_token ) {
        if ( my $tag = $token->get_tag ) {
            if ( $tag eq 'a' and defined(my $href = $token->get_attr('href') ) ) {
                if ($href =~ /files\/book${book_id}_(\d+)\.htm/) {
                    my $chapter_id = $1;
                    my $text = $p->peek;
                    push @urls, {
                        chapter_id => $chapter_id,
                        url => "http://www.wxsky.net/files/book${book_id}_$chapter_id.htm",
                        text => $text,
                    };
                }
            }
        }
    }
    
    my $html;
    foreach (@urls) {
        $html .= "<li><a href='wxsky$book_id/$_->{chapter_id}.html'>$_->{text}</a></li>\n";
    }
    open(my $fh, '>', "$book_id.html");
    print $fh $html;
    close($fh);
    
    return @urls;
}

sub parse_chapter {
    my ($ua, $chapter_id, $url, $next_chapter_id) = @_;
    
    # skip if already get
    return if (-e "wxsky$book_id/$chapter_id.html");
    
    $ua->get($url);
    my $content = $ua->content;
    
    my $text;
    
    my $p = HTML::TokeParser::Simple->new( string => $content );
    while ( my $token = $p->get_token ) {
        if ( my $tag = $token->get_tag ) {
            if ( $tag eq 'script' and defined(my $src = $token->get_attr('src') ) ) {
                if ($src =~ /txtfiles\/\d+\/\d+\.txt/) {
                    my $url = "http://www.wxsky.net$src";
                    print "Get $url\n";
                    $ua->get($url);
                    $text = $ua->content;
                    # <img src=/EdPic/UpPics/2008/8/29/08829633596335563497798275000.gif border=0>
                    my @imgs = ($text =~ /img src=(.*?)\s+/isg);
                    foreach my $img_url (@imgs)  {
                        my ($img_name) = ($img_url =~ /\/([^\/]*?)$/);
                        my $store_file = "wxsky$book_id/$img_name";
                        # get store the img
                        $ua->get( $img_url, ':content_file' => $store_file );
                        $text =~ s/$img_url/$img_name/s;
                    }
                }
            }
        }
    }
    
    if ($text) {
        $text = <<HTML;
<html><head>
<META http-equiv=Content-Type content="text/html; charset=gb2312">
</head><body>
<script>$text</script>
<script>
var nextpage2= '$next_chapter_id.html';
document.onkeydown=nextpage;
function nextpage(event) {
	event = event ? event : (window.event ? window.event : null); 
	if (event.keyCode==39) location=nextpage2
}
</script>
<h2><a href="$next_chapter_id.html">Next</a></h2>
</body></html>
HTML
        open(my $fh, '>', "wxsky$book_id/$chapter_id.html");
        print $fh $text;
        close($fh);
    } else {
        print "ERROR on $url\n";
    }
}

1;