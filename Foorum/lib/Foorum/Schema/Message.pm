package Foorum::Schema::Message;

use base qw/DBIx::Class/;
use DateTime::Format::MySQL;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('message');
__PACKAGE__->add_columns(qw/
    message_id from_id to_id title text post_on post_ip
/);
__PACKAGE__->set_primary_key('message_id');
__PACKAGE__->has_one('sender' => 'Foorum::Schema::User', { 'foreign.user_id' => 'self.from_id' } );
__PACKAGE__->has_one('recipient' => 'Foorum::Schema::User', { 'foreign.user_id' => 'self.to_id' } );

__PACKAGE__->inflate_column('post_on', {
    inflate => sub { shift; },
    deflate => sub { DateTime::Format::MySQL->format_datetime(shift); },
});

1;