package Foorum::Schema::LogAction;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('log_action');
__PACKAGE__->add_columns(qw/
    user_id action object_type object_id time
/);

1;