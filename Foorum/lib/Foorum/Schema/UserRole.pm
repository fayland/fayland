package Foorum::Schema::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "role",
  { data_type => "ENUM", default_value => "user", is_nullable => 1, size => 9 },
  "field",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key(qw/user_id role field/);

# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 17:59:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8Lk8TAfLs99rnR0X2TLU2A


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->belongs_to(
    'user' => 'Foorum::Schema::User',
    { 'foreign.user_id' => 'self.user_id' }
);
1;
