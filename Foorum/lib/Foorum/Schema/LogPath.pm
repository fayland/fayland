package Foorum::Schema::LogPath;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("log_path");
__PACKAGE__->add_columns(
  "session_id",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 72,
  },
  "user_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 9 },
  "path",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 255 },
  "get",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "post",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "time",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 1,
    size => 14,
  },
  "loadtime",
  { data_type => "FLOAT", default_value => "0.00", is_nullable => 0, size => 32 },
);


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 19:02:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lniJUZA/iKpa9FC5o5krNg









# You can replace this text with custom content, and it will be preserved on regeneration
1;
