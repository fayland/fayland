package Foorum::Schema::BannedIP;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('banned_ip');
__PACKAGE__->add_columns(
    qw/
        ip_id cidr_ip time
        /
);
__PACKAGE__->set_primary_key('ip_id');

1;
