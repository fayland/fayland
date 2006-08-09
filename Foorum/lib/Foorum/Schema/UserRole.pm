package Foorum::Schema::UserRole;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('user_role');
__PACKAGE__->add_columns(qw/
    user_id role field
/);
__PACKAGE__->set_primary_key(qw/user_id role field/);


1;