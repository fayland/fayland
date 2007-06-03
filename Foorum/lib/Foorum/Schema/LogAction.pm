package Foorum::Schema::LogAction;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('log_action');
__PACKAGE__->add_columns(qw/
    user_id action object_type object_id time text forum_id
/);

__PACKAGE__->might_have('operator' => 'Foorum::Schema::User', { 'foreign.user_id' => 'self.user_id' } );

1;