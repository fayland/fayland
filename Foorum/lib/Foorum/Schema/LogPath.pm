package Foorum::Schema::LogPath;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('log_path');
__PACKAGE__->add_columns(qw/
    session_id user_id path get post time loadtime
/);

1;