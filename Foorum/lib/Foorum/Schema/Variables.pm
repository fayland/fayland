package Foorum::Schema::Variables;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('variables');
__PACKAGE__->add_columns(
    qw/
        type name value
        /
);
__PACKAGE__->set_primary_key(qw/type name/);

1;
