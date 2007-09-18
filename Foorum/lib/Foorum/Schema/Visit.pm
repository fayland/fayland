package Foorum::Schema::Visit;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("visit");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "object_type",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "object_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "time",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
);


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 17:59:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:huZ796AlaWh+T/8msvGcjA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
