package Foorum::Schema::UserActivation;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_activation");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INT", default_value => "", is_nullable => 0, size => 11 },
  "activation_code",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "new_email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 18:29:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ha3XTNv0wuB9qLzSBBmjfg




# You can replace this text with custom content, and it will be preserved on regeneration
1;
