package Foorum::Schema::LogError;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('log_error');
__PACKAGE__->add_columns(
    qw/
        error_id level text time
        /
);
__PACKAGE__->set_primary_key(qw/error_id/);

1;
