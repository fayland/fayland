package Foorum::Schema::UserDetails;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('user_details');
__PACKAGE__->add_columns(
    qw/
        user_id qq msn gtalk yahoo skype homepage birthday
        /
);
__PACKAGE__->set_primary_key('user_id');

__PACKAGE__->belongs_to(
    'user' => 'Foorum::Schema::User',
    { 'foreign.user_id' => 'self.user_id' }
);

1;
