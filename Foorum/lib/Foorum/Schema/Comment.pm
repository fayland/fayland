package Foorum::Schema::Comment;

use base qw/DBIx::Class/;
use DateTime::Format::MySQL;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('comment');
__PACKAGE__->add_columns(qw/
    comment_id reply_to author_id title text post_on update_on post_ip formatter
    object_type object_id forum_id
/);
__PACKAGE__->set_primary_key('comment_id');
__PACKAGE__->might_have('author' => 'Foorum::Schema::User', { 'foreign.user_id' => 'self.author_id' } );

__PACKAGE__->inflate_column('post_on', {
    inflate => sub { shift; },
    deflate => sub { DateTime::Format::MySQL->format_datetime(shift); },
});
__PACKAGE__->inflate_column('update_on', {
    inflate => sub { shift; },
    deflate => sub { DateTime::Format::MySQL->format_datetime(shift); },
});

1;