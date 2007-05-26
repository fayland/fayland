package Foorum::Model::Object;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;
use Switch;

sub get_object_from_url {
    my ($self, $c, $path) = @_;
    
    my ($object_id, $object_type, $forum_code);
    # 1. poll, eg: /forum/ForumName/poll/2
    if ($path =~ /\/forum\/(\w+)\/poll\/(\d+)/) {
        $forum_code = $1;
        $object_id = $2; # poll_id
        $object_type = 'poll';
    }
    # 2. user profile, eg: /u/fayland
    elsif ($path =~ /\/u\/(\w+)/) {
        my $user_id = $c->model('User')->get_user_id_from_username($c, $1);
        $object_id  = $user_id;
        $object_type = 'user_profile';
    }
    
    return ($object_id, $object_type, $forum_code);
}

sub get_url_from_object {
    my ($self, $c, $info) = @_;
    
    my $object_type = $info->{object_type};
    my $object_id   = $info->{object_id};
    my $forum_id    = $info->{forum_id};
    
    switch ($object_type) {
        case 'poll' { return "/forum/$forum_id/poll/$object_id"; }
        case 'user_profile' {
            my $username = $c->model('User')->get_username_from_user_id($c, $object_id);
            return "/u/$username" if ($username);
        }
    }
}

sub get_object_by_type_id {
    my ($self, $c, $info) = @_;
    
    my $object_type = $info->{object_type};
    my $object_id   = $info->{object_id};
    return unless ($object_type and $object_id);
    
    my $object;
    switch ($object_type) {
        case 'topic' {
            $object = $c->model('DBIC::Topic')->find( {
                topic_id => $object_id,
            }, {
                prefetch => ['author'],
            } );
            return unless ($object);
            $object->{url} = '/forum/' . $object->forum_id . "/$object_id";
        }
        case 'poll' {
            $object = $c->model('DBIC::Poll')->find( {
                poll_id => $object_id,
            }, {
                prefetch => ['author'],
            } );
            return unless ($object_id);
            $object->{url} = '/forum/' . $object->forum_id . "/poll/$object_id";
        }
    }
    return $object;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
