package Foorum::Schema::Visit;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('visit');
__PACKAGE__->add_columns(
    qw/
        user_id object_type object_id time
        /
);
__PACKAGE__->set_primary_key(qw/user_id object_type object_id/);

1;
