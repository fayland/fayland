package Foorum::Schema::MessageUnread;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('message_unread');
__PACKAGE__->add_columns(
    qw/
        user_id message_id
        /
);
__PACKAGE__->set_primary_key(qw/user_id message_id/);

1;
