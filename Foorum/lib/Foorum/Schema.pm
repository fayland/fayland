package Foorum::Schema;

use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/
    User
    UserRole
    Forum
    Topic
    Comment
    Session
    Category
    Board
    Page
    EmailSetting
    Message
    MessageUnread
    Poll
    PollOption
    PollResult
    Star
    Upload
    LogPath
/);

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;