package Foorum::Schema::Topic;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('topic');
__PACKAGE__->add_columns(qw/
    topic_id forum_id title closed sticky elite author_id hit last_updator_id last_update_date total_replies
/);
__PACKAGE__->set_primary_key('topic_id');
__PACKAGE__->might_have('author' => 'Foorum::Schema::User', { 'foreign.user_id' => 'self.author_id' } );
__PACKAGE__->might_have('last_updator' => 'Foorum::Schema::User', { 'foreign.user_id' => 'self.last_updator_id' } );

1;