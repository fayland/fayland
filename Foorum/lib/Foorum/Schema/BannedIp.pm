package Foorum::Schema::BannedIp;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("banned_ip");
__PACKAGE__->add_columns(
  "ip_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "cidr_ip",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 20 },
  "time",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("ip_id");


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 18:48:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Je/ZPRGzMyaLTaf6SIY8zg






# You can replace this text with custom content, and it will be preserved on regeneration
1;
