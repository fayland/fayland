package Foorum::Schema::User;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/
    user_id username password nickname gender birthday email homepage register_on
    register_ip active_code last_login_on last_login_ip has_actived login_times
    status threads replies last_post_id
/);
__PACKAGE__->set_primary_key('user_id');
__PACKAGE__->add_unique_constraint(
     ['username'], ['email'],
);

__PACKAGE__->might_have('last_post' => 'Foorum::Schema::Topic', { 'foreign.topic_id' => 'self.last_post_id' } );
__PACKAGE__->has_many('roles' => 'Foorum::Schema::UserRole', { 'foreign.user_id' => 'self.user_id' } );

1;