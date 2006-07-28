#!/usr/bin/perl

# SVN ID: $Id: SimpleFeed.pm 29 2005-03-10 02:09:08Z minter $

package XML::Atom::SimpleFeed;

$VERSION = "0.5";

use warnings;
use strict;

sub new
{
    my ( $class, %arg ) = @_;
    my %feed;
    my @entries;

    $feed{title}    = _encode_xml( $arg{title} )    || return;
    $feed{link}     = _encode_xml( $arg{link} )     || return;
    $feed{modified} = _encode_xml( $arg{modified} ) || _generate_now_w3cdtf();
    $feed{tagline}  = _encode_xml( $arg{tagline} );
    $feed{generator} = _encode_xml( $arg{generator} )
      || "XML::Atom::SimpleFeed $XML::Atom::SimpleFeed::VERSION";
    $feed{copyright} = _encode_xml( $arg{copyright} );
    $feed{info}      = _encode_xml( $arg{info} );
    $feed{id}        = _encode_xml( $arg{id} );
    if ( $arg{author} )
    {

        # If you're supplying an author, you've got to have a name.
        return unless $arg{author}->{name};
        %{ $feed{author} } =
          map { $_ => _encode_xml( $arg{author}->{$_} ) }
          keys( %{ $arg{author} } );
    }

    bless { _feed => \%feed, _entries => \@entries }, $class;
}

sub add_entry
{
    my ( $self, %arg ) = @_;

    my %entry;

    $entry{title} = _encode_xml( $arg{title} ) || return;
    $entry{link}  = _encode_xml( $arg{link} )  || return;

    if ( $arg{author} )
    {
        return unless $arg{author}->{name};
        %{ $entry{author} } =
          map { $_ => _encode_xml( $arg{author}->{$_} ) }
          keys( %{ $arg{author} } );
    }
    elsif ( $self->{_feed}{author} )
    {
        $entry{author} = undef;
    }
    else
    {
        return;
    }
    $entry{modified} = _encode_xml( $arg{modified} ) || _generate_now_w3cdtf();
    $entry{issued}   = _encode_xml( $arg{issued} )   || _generate_now_w3cdtf();
    $entry{id}       = _encode_xml( $arg{id} )
      || _generate_entry_id( $entry{link}, $entry{issued} );

    $entry{created} = _encode_xml( $arg{created} );
    $entry{summary} = _encode_xml( $arg{summary} );
    $entry{content} = $arg{content};
    $entry{content} =~ s/]]>/]]&gt;/g if $entry{content};
    $entry{content} =~ s/<!\[CDATA\[/&lt;![CDATA[/g if $entry{content};
    $entry{subject} = _encode_xml( $arg{subject} );

    push( @{ $self->{_entries} }, \%entry );

}

sub print
{
    my $self       = shift;
    my $feedstring = as_string($self);

    print $feedstring;
}

sub save_file
{
    my $self = shift;
    my $arg = shift or return;
    my $fh;

    if ( ref $arg eq "GLOB" )
    {
        $fh = $arg;
    }
    else
    {
        open( $fh, ">", $arg ) or return;
    }

    my $feedstring = as_string($self);
    print $fh $feedstring;
}

sub _encode_xml
{
    my $string = shift or return;
    $string =~ s/&/&amp;/g;
    $string =~ s/</&lt;/g;

    return $string;
}

sub as_string
{

# This is somewhat kludgy, as it's just outputting simple strings instead of
# doing "real XML" stuff.  But, it should work well enough in the general case
# and, if you need real XML shizzle, there are plenty of real XML modules out there.
# :-)

    my $self = shift;

    my $string;

    $string .= qq|<?xml version="1.0" encoding="UTF-8"?>\n|;
    $string .=
      qq|<feed version="0.3" xmlns="http://purl.org/atom/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">\n|;
    $string .= qq|  <title>$self->{_feed}{title}</title>\n|;
    $string .=
      qq|  <link rel="alternate" type="text/html" href="$self->{_feed}{link}" />\n|;
    $string .= qq|  <modified>$self->{_feed}{modified}</modified>\n|;
    $string .= qq|  <id>$self->{_feed}{id}</id>\n| if $self->{_feed}{id};
    $string .= qq|  <tagline>$self->{_feed}{tagline}</tagline>\n|
      if $self->{_feed}{tagline};

    if ( $self->{_feed}{author} )
    {
        $string .= qq|  <author>\n|;
        $string .= qq|    <name>$self->{_feed}{author}{name}</name>\n|
          if $self->{_feed}{author}{name};
        $string .= qq|    <email>$self->{_feed}{author}{email}</email>\n|
          if $self->{_feed}{author}{email};
        $string .= qq|    <url>$self->{_feed}{author}{url}</url>\n|
          if $self->{_feed}{author}{url};
        $string .= qq|  </author>\n|;
    }
    $string .= qq|  <generator>$self->{_feed}{generator}</generator>\n|
      if $self->{_feed}{generator};
    $string .= qq|  <copyright>$self->{_feed}{copyright}</copyright>\n|
      if $self->{_feed}{copyright};

    foreach my $entry ( @{ $self->{_entries} } )
    {
        $string .= qq|  <entry>\n|;
        $string .= qq|    <title>$entry->{title}</title>\n|;
        $string .=
          qq|    <link rel="alternate" type="text/html" href="$entry->{link}" />\n|;
        $string .= qq|      <modified>$entry->{modified}</modified>\n|;
        $string .= qq|      <issued>$entry->{issued}</issued>\n|;
        $string .= qq|      <id>$entry->{id}</id>\n|;
        $string .= qq|      <created>$entry->{created}</created>\n|
          if $entry->{created};
        $string .= qq|      <summary>$entry->{summary}</summary>\n|
          if $entry->{summary};

        if ( $entry->{author} )
        {
            $string .= qq|      <author>\n|;
            $string .= qq|        <name>$entry->{author}{name}</name>\n|
              if $entry->{author}{name};
            $string .= qq|        <email>$entry->{author}{email}</email>\n|
              if $entry->{author}{email};
            $string .= qq|        <url>$entry->{author}{url}</url>\n|
              if $entry->{author}{url};
            $string .= qq|      </author>\n|;
        }
        $string .= qq|      <dc:subject>$entry->{subject}</dc:subject>\n|
          if $entry->{subject};
        $string .=
          qq|      <content type="text/html" mode="escaped"><![CDATA[$entry->{content}]]></content>\n|
          if $entry->{content};
        $string .= qq|    </entry>\n|;
    }

    $string .= qq|</feed>\n|;

    return $string;
}

sub _generate_now_w3cdtf
{
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday ) = gmtime;
    $year += 1900;
    $mon++;
    my $timestring = sprintf( "%4d-%02d-%02dT%02d:%02d:%02dZ",
        $year, $mon, $mday, $hour, $min, $sec );
    return ($timestring);
}

sub _generate_entry_id
{

    # Generate a UUID for a feed based on Mark Pilgrim's method at
    # http://diveintomark.org/archives/2004/05/28/howto-atom-id

    my ( $link, $modified ) = @_;

    $link =~ s#^.*?://(.*)#$1#;
    $link =~ s|#|/|g;

    $modified =~ /^(\d+-\d+-\d+)/;
    my $datestring = $1;

    $link =~ s#^(.*?)/(.*)$#tag:$1,$datestring:/$2#;
    $link =~ s#/#%2F#g;

    return ($link);
}

1;

__END__

=head1 NAME

XML::Atom::SimpleFeed - Generate simple Atom syndication feeds

=head1 SYNOPSIS

  use XML::Atom::SimpleFeed;

  # Create the feed object
  my $atom = XML::Atom::SimpleFeed->new(
      title    => "My Atom Feed",
      link     => "http://www.example.com/blog/",
      modified => "2005-02-18T15:00:00Z",
      tagline  => "This is an example feed.  Nothing to see here.  Move along."
    )
    or die;

  # Add an entry to the feed
  $atom->add_entry(
      title    => "A Sample Entry",
      link     => "http://www.example.com/blog/entries/1234",
      author   => { name => "J. Random Hacker", email => 'jrh@example.com' },
      modified => "2005-02-18T16:45:00Z",
      issued   => "2005-02-18T15:30:00Z",
      content  => "This is the body of the entry"
    )
    or die;

  # Print out the feed
  $atom->print;

=head1 DESCRIPTION

This module exists to generate basic Atom syndication feeds.  While it does not provide a full, object-oriented interface into all the nooks and crannies of Atom feeds, an Atom parser, or an Atom client API, it should be useful for people who want to generate basic, valid Atom feeds of their content quickly and easily.

=head1 METHODS

=over 4

=item my $atom = XML::Atom::SimpleFeed->new(%args);

This creates a new XML::Atom::SimpleFeed objects with the supplied parameters.  The parameters are supplied as a hash.  Some parameters are required, some are optional.  They are:

=over

=item * title

REQUIRED (string).  The title of the Atom feed.

=item * link

REQUIRED (string).  The URL link of the Atom feed.  Normally points to the home page of the resource you are syndicating.

=item * modified

OPTIONAL (string).  The date the feed was last modified in W3CDTF format.  This is a REQUIRED element in the Atom spec, but if you do not supply it, the current date and time will be used.

=item * tagline

OPTIONAL (string).  A description or tagline for the feed.

=item * generator

OPTIONAL (string).  The software agent used to generate the feed.  If not supplied, will be set to "XML::Atom::SimpleFeed"

=item * copyright

OPTIONAL (string).  The copyright string for the feed.

=item * info

OPTIONAL (string).  A human-readable explanation of the feed format itself.

=item * id 

OPTIONAL (string). A permanent, globally unique identifier for the feed.

=item * author 

OPTIONAL (hash).  A hash of information about the author of the feed.  If this element exists, it will be used to provide author information for a feed entry, if no author information was provided for the entry.  The author hash contains the following information:

=over

=item * name

REQUIRED (string).  The name of the author ("J. Random Hacker")

=item * email

OPTIONAL (string).  The email address of the author ("jrh@example.com")

=item * url

OPTIONAL (string).  The URL of the author ("http://www.example.com/jrh/")

=back

=back

=item $atom->add_entry(%args);

This method adds an entry into the atom feed.  Its arguments are supplied as a hash, with the following keys:

=over

=item * title

REQUIRED (string).  The title of the entry.

=item * link

REQUIRED (string).  The URL to the entry itself.  Should be unique to assure valid feeds.

=item * author

OPTIONAL (hash).  Optional with a caveat.  A hash of information about the author of the entry.  If this element is left blank, the author information for the feed will be used.  If that information was not provided, the method will return undef, since the author is required.

=over

=item * name

REQUIRED (string).  The name of the author ("J. Random Hacker")

=item * email

OPTIONAL (string).  The email address of the author ("jrh@example.com")

=item * url

OPTIONAL (string).  The URL of the author ("http://www.example.com/jrh/")

=back

=item * id

OPTIONAL (string).  Optional with a caveat.  This is the globally unique identifier for the feed.  It should be a string that does not change.  If the id is not provided, the module will attempt to construct one via the link parameter, based on the Mark Pilgrim method.  For more information about generating unique ids in Atom, see L<http://diveintomark.org/archives/2004/05/28/howto-atom-id>

=item * issued

OPTIONAL (string).  The date and time the entry was first published, in W3CDTF format.  A REQUIRED part of the Atom spec.  Should be set once and not changed (if the feed changes, use the modified parameter below).  If this parameter is not provided, the current date and time will be used.

=item * modified

OPTIONAL (string).  The date and time the entry was last modified, in W3CDTF format.  A REQUIRED part of the Atom spec.  This is the date you will change if the contents of the feed are modified.  If this parameter is not provided, the current date and time will be used.

=item * created

OPTIONAL (string).  The date and time the entry was created (differs from "issued" and "modified"), in W3CDTF format.  May often be, but is not necessarily, the same time the entry was issued.

=item * summary

OPTIONAL (string).  A short summary of the entry.

=item * subject

OPTIONAL (string).  The subject of the entry.

=item * content

OPTIONAL (string).  The actual, honest-to-goodness, body of the entry.

=back

=item $atom->as_string();

Returns the text of the atom feed as a scalar.

=item $atom->print();

Outputs the full atom feed to STDOUT;

=item $atom->save_file($file);

Saves the full atom feed into the file referenced by $file.  If $file is a open filehandle, the output will go there.  Otherwise, $file is taken to be the name of a file, which is opened.  If there is a problem opening the filename, undef is returned.

=head1 BUGS

Most likely does not implement all the useful features of an Atom feed.  Comments and patches welcome!

Language is hardcoded as "en"

=head1 SEE ALSO

XML::Atom L<http://search.cpan.org/dist/XML-Atom/>

Atom Enabled L<http://www.atomenabled.org/>

W3CDTF Spec L<http://www.w3.org/TR/NOTE-datetime>

=head1 AUTHOR

H. Wade Minter, E<lt>minter@lunenburg.orgE<gt>
L<http://www.lunenburg.org/>

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by H. Wade Minter

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
