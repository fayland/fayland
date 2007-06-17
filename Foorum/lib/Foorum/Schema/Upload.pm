package Foorum::Schema::Upload;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('upload');
__PACKAGE__->add_columns(
    qw/
        upload_id user_id forum_id filename filesize filetype
        /
);
__PACKAGE__->set_primary_key('upload_id');

1;
