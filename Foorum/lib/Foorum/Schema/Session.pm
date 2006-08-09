package Foorum::Schema::Session;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('session');
__PACKAGE__->add_columns(qw/
    id session_data expires
/);
__PACKAGE__->set_primary_key('id');

1;