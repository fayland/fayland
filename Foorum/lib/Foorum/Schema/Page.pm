package Foorum::Schema::Page;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('page');
__PACKAGE__->add_columns(
    qw/
        id name
        /
);
__PACKAGE__->set_primary_key('id');

1;
