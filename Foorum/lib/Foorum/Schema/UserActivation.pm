package Foorum::Schema::UserActivation;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_activation');
__PACKAGE__->add_columns(qw/
    user_id activation_code
/);
__PACKAGE__->set_primary_key('user_id');

1;