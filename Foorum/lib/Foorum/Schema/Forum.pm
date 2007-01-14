package Foorum::Schema::Forum;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('forum');
__PACKAGE__->add_columns(qw/
    forum_id forum_code name description type policy total_members total_topics total_replies last_post_id
/);
__PACKAGE__->set_primary_key('forum_id');
__PACKAGE__->might_have('last_post' => 'Foorum::Schema::Topic', { 'foreign.topic_id' => 'self.last_post_id' } );
__PACKAGE__->has_many('topics' => 'Foorum::Schema::Topic', { 'foreign.forum_id' => 'self.forum_id' } );

1;