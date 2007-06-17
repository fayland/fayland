package Foorum::Schema::Poll;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('poll');
__PACKAGE__->add_columns(
    qw/
        poll_id forum_id author_id multi anonymous time duration vote_no title
        /
);
__PACKAGE__->set_primary_key('poll_id');
__PACKAGE__->might_have(
    'author' => 'Foorum::Schema::User',
    { 'foreign.user_id' => 'self.author_id' }
);
__PACKAGE__->has_many(
    'options' => 'Foorum::Schema::PollOption',
    { 'foreign.poll_id' => 'self.poll_id' }
);
__PACKAGE__->has_many(
    'results' => 'Foorum::Schema::PollResult',
    { 'foreign.poll_id' => 'self.poll_id' }
);

1;
