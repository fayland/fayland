package WWW::Zorpia::Upload;

use warnings;
use strict;
use vars qw/$VERSION/;
use File::Spec;
use WWW::Mechanize;

$VERSION = '0.03';

sub new {
    my $class = shift;

    my $self = { };
    $self->{ua} = WWW::Mechanize->new(
        agent => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
        cookie_jar => {},
        stack_depth => 1,
    );
	return bless $self => $class;
}

sub login {
    my ($self, $username, $password) = @_;
    
    $self->{_username} = $username;
    $self->{ua}->get('http://www.zorpia.com/login');
    return 0 unless ($self->{ua}->success);
    
    $self->{ua}->submit_form(
        form_name => 'Login',
        fields    => {
            username => $username,
            password => $password,
            'goto'   => '/help',
        },
    );
    return 0 unless ($self->{ua}->success);
    
    my $login = ($self->{ua}->{base}->path =~ /login/) ? 0 : 1;
    $self->{_login_status} = $login;
    return $login;
}

sub upload {
    my ($self, $upload) = @_;
    
    return 0 unless ($self->{_login_status});
    
    my $album_id = ($upload->{album_id} and $upload->{album_id} =~ /^\d+$/) ? $upload->{album_id} : -1;
    my $upload_file;
    if ($upload->{url}) {
        # get file to local first
        my $tmpdir = File::Spec->tmpdir();
        my $tmpfile = File::Spec->catfile( $tmpdir, $self->{_username} . time() );
        $self->{ua}->get( $upload->{url}, ":content_file" => $tmpfile );
        return 0 unless ($self->{ua}->success);
        $upload_file = $tmpfile;
    } elsif ($upload->{file}) {
        $upload_file = $upload->{file};
    } else { return 0; }
    return 0 unless (-e $upload_file);
    
    my $upload_url = 'http://www.zorpia.com/photo/html_form/' . $album_id;
    $upload_url .= '/' . $upload->{group_code} if ($upload->{group_code});
    $self->{ua}->get($upload_url);
    return 0 unless ($self->{ua}->success);
    $self->{ua}->submit_form(
        form_name => 'Upload_JPEG',
        fields    => {
            SourceFile_1 => $upload_file,
        },
    );
    
    # remove tmpfile
    if ($upload->{url}) {
        unlink $upload_file;
    }
    
    return 0 unless ($self->{ua}->success);
    return 1;
}

sub upload_for_group {
    my ($self, $upload) = @_;
    
    return 0 unless ($upload->{group_code});
    return $self->upload($upload);
}

1;
__END__

=head1 NAME

WWW::Zorpia::Upload - upload photos to www.zorpia.com

=head1 SYNOPSIS

    use WWW::Zorpia::Upload;

    my $zorpia = WWW::Zorpia::Upload->new();
    $zorpia->login('username', 'password');
    
    # upload files in local machine
    $zorpia->upload( {
        file => '/home/fayland/upload.gif',
        album_id => 12345, # optional, default is -1 ( profile album )
                           # be sure that's your album
    } );
    
    # upload internet pictures
    $zorpia->upload( {
        url => 'http://www.fayland.org/images/camel/kiss.jpg',
        album_id => -1, # optional, the same as above
    } );
    
    # upload a photo to a group
    $zorpia->upload_for_group( {
        file => 'E:/Fayland/love.jpg',
        album_id => '780190',
        group_code => 'faylands_group',
    } );

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Zorpia L<http://www.zorpia.com> Company Ltd.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland Lam and Zorpia Company Ltd., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
