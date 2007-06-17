package Foorum::Schema::Message;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('message');
__PACKAGE__->add_columns(
    qw/
        message_id from_id to_id title text post_on post_ip from_status to_status
        /
);
__PACKAGE__->set_primary_key('message_id');
__PACKAGE__->has_one(
    'sender' => 'Foorum::Schema::User',
    { 'foreign.user_id' => 'self.from_id' }
);
__PACKAGE__->has_one(
    'recipient' => 'Foorum::Schema::User',
    { 'foreign.user_id' => 'self.to_id' }
);

1;
