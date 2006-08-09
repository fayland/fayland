package Foorum::Schema::EmailSetting;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('email_setting');
__PACKAGE__->add_columns(qw/
    user_id object_type frequence
/);
__PACKAGE__->set_primary_key(qw/user_id object_type/);

1;