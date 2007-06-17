package Foorum::Schema::Category;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('category');
__PACKAGE__->add_columns(
    qw/
        id name parent_id level
        /
);
__PACKAGE__->set_primary_key('id');

1;
