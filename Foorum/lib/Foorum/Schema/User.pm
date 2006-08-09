package Foorum::Schema::User;

use base qw/DBIx::Class/;
use DateTime::Format::MySQL;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/
    user_id username password nickname gender birthday email homepage register_on
    register_ip active_code last_login_on last_login_ip has_actived login_times
    status
/);
__PACKAGE__->set_primary_key('user_id');

__PACKAGE__->inflate_column('register_on', {
    inflate => sub { shift; },
    deflate => sub { DateTime::Format::MySQL->format_datetime(shift); },
});
__PACKAGE__->inflate_column('last_login_on', {
    inflate => sub { shift; },
    deflate => sub { DateTime::Format::MySQL->format_datetime(shift); },
});

1;