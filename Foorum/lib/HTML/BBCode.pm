package HTML::BBCode;

=head1 NAME

HTML::BBCode - Perl extension for converting BBcode to HTML.

=head1 SYNOPSIS

  use HTML::BBCode;

  my $bbc  = HTML::BBCode->new( \%options );
  my $html = $bbc->parse($bbcode);

  # Input
  print $bbc->{bbcode};

  # Output
  print $bbc->{html};

=head1 DESCRIPTION

C<HTML::BBCode> converts BBCode -as used on the phpBB bulletin
boards- to its HTML equivalent.

=head2 METHODS

The following methods can be used

=head3 new

   my $bbc = HTML::BBCode->new({
      allowed_tags => [ @bbcode_tags ],
      html_tags    => \%html_tags,
      no_html      => 1,
      no_jslink    => 1,
      linebreaks   => 1,
   });

C<new> creates a new C<HTML::BBCode> object using the configuration
passed to it. The object's default configuration allows all BBCode to
be converted to the default HTML.

=head4 options

=over 5

=item allowed_tags

Defaults to all currently know C<BBCode tags>, being:
b, u, i, color, size, quote, code, list, url, email, img. With this
option, you can specify what BBCode tags you would like to convert.

=item html_tags

Configures the wanted output in HTML. Defaults to (almost) the same as
used on the phpbb bulletin boards (<b>, <u> etc. have been turned into
their CSS equivalents).

=item no_html

Disabled by default.

When true, HTML tags will be converted from '<br />' to '&lt;br /&gt;'

=item no_jslink

Enabled by default.

When true, links like C<javascript:foo(bar)> will be disabled.

=item linebreaks

Disabled by default.

When true, will substitute linebreaks into HTML ('<br />')

=back

=head3 parse

   my $html = $bbc->parse($bbcode);

Parses text supplied as a single scalar string and returns the HTML as
a single scalar string.

=head1 SEE ALSO

=over 4

=item * L<http://www.phpbb.com/phpBB/faq.php?mode=bbcode>

=item * L<http://menno.b10m.net/perl/>

=item * L<HTML::BBReverse>, L<BBCode::Parser>

=back

=head1 BUGS

C<Bugs? Impossible!>. Please report bugs to L<http://rt.cpan.org/Ticket/Create.html?Queue=HTML-BBCode>.

=head1 AUTHOR

M. Blom, E<lt>blom@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004,2005,2006 by M. Blom

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#------------------------------------------------------------------------------#
use strict;
use warnings;

our $VERSION = '1.05';
our @bbcode_tags
    = qw(code quote b u i color size list url email img font align flash music);

sub new {
    my ( $class, $args ) = @_;
    $args ||= {};
    $class->_croak("Options must be a hash reference")
        if ref($args) ne 'HASH';
    my $self = {};
    bless $self, $class;
    $self->_init($args) or return undef;

    return $self;
}

sub _init {
    my ( $self, $args ) = @_;

    my %html_tags = (
        code => '<div class="bbcode_code_header">Code:</div>'
            . '<div class="bbcode_code_body">%s</div>',
        quote => '<div class="bbcode_quote_header">%s</div>'
            . '<div class="bbcode_quote_body">%s</div>',
        b         => '<span style="font-weight: bold">%s</span>',
        u         => '<span style="text-decoration: underline;">%s</span>',
        i         => '<span style="font-style: italic">%s</span>',
        color     => '<span style="color: %s">%s</span>',
        size      => '<span style="font-size: %spt">%s</span>',
        font      => '<span style="font-family: %s">%s</span>',
        url       => '<a href="%s">%s</a>',
        email     => '<a href="mailto:%s">%s</a>',
        img       => '<img src="%s" alt="" />',
        ul        => '<ul>%s</ul>',
        ol_number => '<ol>%s</ol>',
        ol_alpha  => '<ol style="list-style-type: lower-alpha;">%s</ol>',
        align     => '<div style="text-align: %s">%s</div>',
        flash =>
            q!<div class='flash'><embed src='%s' width='480' height='360'></embed></div>!,
    );

    my %options = (
        allowed_tags => \@bbcode_tags,
        html_tags    => \%html_tags,
        no_html      => 0,
        no_jslink    => 1,
        linebreaks   => 0,
        %{$args},
    );
    $self->{options} = \%options;
    return $self;
}

# Parse the input!
sub parse {
    my ( $self, $bbcode ) = @_;
    return if ( !defined $bbcode );

    $self->{_stack}            = ();
    $self->{_in_code_block}    = 0;
    $self->{_skip_nest}        = '';
    $self->{_nest_count}       = 0;
    $self->{_nest_count_stack} = 0;
    $self->{_dont_nest}        = [ 'code', 'url', 'email', 'img' ];
    $self->{bbcode}            = '';
    $self->{html}              = '';

    $self->{bbcode} = $bbcode;
    my $input = $bbcode;

main:
    while (1) {

        # End tag
        if ( $input =~ /^(\[\/[^\]]+\])/s ) {
            my $end = lc $1;
            if ((      $self->{_skip_nest} ne ''
                    && $end                ne "[/$self->{_skip_nest}]"
                )
                || ( $self->{_in_code_block} && $end ne "[/code]" )
                )
            {
                _content( $self, $end );
            } else {
                _end_tag( $self, $end );
            }
            $input = $';
        }

        # Opening tag
        elsif ( $input =~ /^(\[[^\]]+\])/s ) {
            if ( $self->{_in_code_block} ) {
                _content( $self, $1 );
            } else {
                _open_tag( $self, $1 );
            }
            $input = $';
        }

        # None BBCode content till next tag
        elsif ( $input =~ /^([^\[]+)/s ) {
            _content( $self, $1 );
            $input = $';
        }

        # BUG #14138 unmatched bracket, content till end of input
        elsif ( $input =~ /^(.+)$/s ) {
            _content( $self, $1 );
            $input = $';
        }

        # Now what?
        else {
            last main if ( !$input );    # We're at the end now, stop parsing!
        }
    }
    $self->{html} = join( '', @{ $self->{_stack} } );

    # emot
    my $html = $self->{html};
    return $html unless ( $html =~ /\:\w{2,9}\:/s );
    my @emot_icon = (
        'wink',     'sad',      'biggrin', 'cheesy',
        'confused', 'cool',     'angry',   'sads',
        'smile',    'smiled',   'unhappy', 'dozingoff',
        'blink',    'blush',    'crazy',   'cry',
        'bigsmile', 'inlove',   'notify',  'shifty',
        'sick',     'sleeping', 'sneaky2', 'tounge',
        'unsure',   'wacko',    'why',     'wow',
        'mad',      'Oo'
    );
    my $emot_url = '/static/images/bbcode/emot';
    foreach my $em (@emot_icon) {
        next unless ( $html =~ /\:$em\:/s );
        $html =~ s/\:$em\:/\<img src=\"$emot_url\/$em.gif\"\>/sg;
        last unless ( $html =~ /\:\w{2,9}\:/s );
    }
    $self->{html} = $html;

    return $self->{html};
}

sub _open_tag {
    my ( $self, $open ) = @_;
    my ( $tag, $rest )
        = $open =~ m/\[([^=\]]+)(.*)?\]/s;    # Don't do this! ARGH!
    $tag = lc $tag;
    if ( _dont_nest( $self, $tag ) && $tag eq 'img' ) {
        $self->{_skip_nest} = $tag;
    }
    if ( $self->{_skip_nest} eq $tag ) {
        $self->{_nest_count}++;
        $self->{_nest_count_stack}++;
    }
    $self->{_in_code_block}++ if ( $tag eq 'code' );
    push @{ $self->{_stack} }, '[' . $tag . $rest . ']';
}

sub _content {
    my ( $self, $content ) = @_;
    if ( $self->{options}->{no_html} ) {
        $content =~ s|<|&lt;|gs;
        $content =~ s|>|&gt;|gs;
    }
    $content =~ s|\r*||gs;
    $content =~ s|\n|<br />\n|gs
        if ( $self->{options}->{linebreaks}
        && $self->{_in_code_block} == 0 );
    push @{ $self->{_stack} }, $content;
}

sub _end_tag {
    my ( $self, $end ) = @_;
    my ( $tag, $arg );
    my @buf = ($end);

    if ( "[/$self->{_skip_nest}]" eq $end && $self->{_nest_count} > 1 ) {
        push @{ $self->{_stack} }, $end;
        $self->{_nest_count}--;
        return;
    }

    $self->{_in_code_block} = 0 if ( $end eq '[/code]' );

    # Loop through the stack
    while (1) {
        my $item = pop( @{ $self->{_stack} } );
        push @buf, $item;

        if ( !defined $item ) {
            map { push @{ $self->{_stack} }, $_ if ($_) } reverse @buf;
            last;
        }

        if ( "[$self->{_skip_nest}]" eq "$item" ) {
            $self->{_nest_count_stack}--;
            next if ( $self->{_nest_count_stack} > 0 );
        }

        $self->{_nest_count}--
            if ( "[/$self->{_skip_nest}]" eq $end
            && $self->{_nest_count} > 0 );

        if ( $item =~ /\[([^=\]]+).*\]/s ) {
            $tag = $1;
            if ( $tag && $end eq "[/$tag]" ) {
                push @{ $self->{_stack} },
                    ( _is_allowed( $self, $tag ) )
                    ? _do_BB( $self, @buf )
                    : reverse @buf;

                # Clear the _skip_nest?
                $self->{_skip_nest} = ''
                    if ( defined $self->{_skip_nest}
                    && $tag eq $self->{_skip_nest} );
                last;
            }
        }
    }
    $self->{_nest_count_stack} = 0;
}

sub _do_BB {
    my ( $self, @buf ) = @_;
    my ( $tag, $attr );
    my $html;

    # Get the opening tag
    my $open = pop(@buf);

    # We prefer to read in non-reverse way
    @buf = reverse @buf;

    # Closing tag is kinda useless, pop it
    pop(@buf);

    # Rest should be content;
    my $content = join( ' ', @buf );

    # What are we dealing with anyway? Any attributes maybe?
    if ( $open =~ /\[([^=\]]+)=?([^\]]+)?]/ ) {
        $tag  = $1;
        $attr = $2;
    }

    # Kludgy way to handle specific BBCodes ...
    if ( $tag eq 'quote' ) {
        $html = sprintf( $self->{options}->{html_tags}->{quote},
            ($attr)
            ? "$attr wrote:"
            : "Quote:", $content );
    } elsif ( $tag eq 'code' ) {
        $html = sprintf( $self->{options}->{html_tags}->{code},
            _code($content) );
    } elsif ( $tag eq 'list' ) {
        $html = _list( $self, $attr, $content );
    } elsif ( ( $tag eq 'email' || $tag eq 'url' ) && !$attr ) {
        $content =~ s|javascript:||g if ( $self->{options}->{no_jslink} );
        $html = sprintf( $self->{options}->{html_tags}->{$tag},
            $content, $content );
    } elsif ( $tag eq 'music' ) {

        # patch for music
        if ( $content =~ /\.(ram|rmm|mp3|mp2|mpa|ra|mpga)$/ ) {
            $html
                = qq!<div><embed name="rplayer" type="audio/x-pn-realaudio-plugin" src="$content" 
controls="StatusBar,ControlPanel" width='320' height='70' border='0' autostart='flase'></embed></div>!;
        } elsif ( $content =~ /\.(rm|mpg|mpv|mpeg|dat)$/ ) {
            $html
                = qq!<div><embed name="rplayer" type="audio/x-pn-realaudio-plugin" src="$content" 
controls="ImageWindow,StatusBar,ControlPanel" width='352' height='288' border='0' autostart='flase'></embed></div>!;
        } elsif ( $content =~ /\.(wma|mpa)$/ ) {
            $html
                = qq!<div><embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/Downloads/Contents/Products/MediaPlayer/" src="$content" name="realradio" showcontrols='1' ShowDisplay='0' ShowStatusBar='1' width='480' height='70' autostart='0'></embed></div>!;
        } elsif ( $content =~ /\.(asf|asx|avi|wmv)$/ ) {
            $html
                = qq!<div><object id="videowindow1" width="480" height="330" classid="CLSID:6BF52A52-394A-11D3-B153-00C04F79FAA6"><param NAME="URL" value="$content"><param name="AUTOSTART" value="0"></object></div>!;
        }
    } elsif ($attr) {
        $attr =~ s|javascript:||g if ( $self->{options}->{no_jslink} );

        # specail treat for size
        if ( $tag eq 'size' ) {
            $attr = 8  if ( $attr < 8 );
            $attr = 16 if ( $attr > 16 );
        }
        $html = sprintf( $self->{options}->{html_tags}->{$tag}, $attr,
            $content );
    } else {
        $content =~ s|javascript:||g if ( $self->{options}->{no_jslink} );
        $html = sprintf( $self->{options}->{html_tags}->{$tag}, $content );
    }

    # Return ...
    return $html;
}

sub _is_allowed {
    my ( $self, $check ) = @_;
    map { return 1 if ( $_ eq $check ); }
        @{ $self->{options}->{allowed_tags} };
    return 0;
}

sub _dont_nest {
    my ( $self, $check ) = @_;
    map { return 1 if ( $_ eq $check ); } @{ $self->{_dont_nest} };
    return 0;
}

sub _code {
    my $code = shift;
    $code =~ s|^\s+?[\n\r]+?||;
    $code =~ s|<|\&lt;|g;
    $code =~ s|>|\&gt;|g;
    $code =~ s|\[|\&#091;|g;
    $code =~ s|\]|\&#093;|g;
    $code =~ s| |\&nbsp;|g;
    $code =~ s|\n|<br />|g;
    return $code;
}

sub _list {
    my ( $self, $attr, $content ) = @_;
    $content =~ s|^<br />[\s\r\n]*|\n|s;
    $content =~ s|\[\*\]([^(\[]+)|_list_removelastbr($1)|egs;
    $content =~ s|<br />$|\n|s;
    if ($attr) {
        return sprintf( $self->{options}->{html_tags}->{ol_number}, $content )
            if ( $attr =~ /^\d/ );
        return sprintf( $self->{options}->{html_tags}->{ol_alpha}, $content )
            if ( $attr =~ /^\D/ );
    } else {
        return sprintf( $self->{options}->{html_tags}->{ul}, $content );
    }
}

sub _list_removelastbr {
    my $content = shift;
    $content =~ s|<br />[\s\r\n]*$||;
    $content =~ s|^\s*||;
    $content =~ s|\s*$||;
    return "<li>$content</li>\n";
}

sub _croak {
    my ( $class, @error ) = @_;
    require Carp;
    Carp::croak(@error);
}

1;
