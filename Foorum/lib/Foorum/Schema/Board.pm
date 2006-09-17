package Foorum::Schema::Board;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('board');
__PACKAGE__->add_columns(qw/
    forum_id page_id squence category_id
/);
__PACKAGE__->set_primary_key('forum_id');

1;