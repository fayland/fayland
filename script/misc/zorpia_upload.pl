#!/usr/bin/perl
use strict;
use Data::Dumper;
#use lib 'E:/Fayland/googlesvn/trunk/CPAN/WWW-Zorpia-Upload/lib';
use WWW::Zorpia::Upload;

my $zorpia = WWW::Zorpia::Upload->new();
$zorpia->login('username', 'password');

    # upload a photo to a group
    my $status = $zorpia->upload_for_group( {
        file => 'E:/Fayland/loves.gif',
        album_id => '780190',
        group_code => 'faylands_group',
    } );

    print $status;