package CatalystX::Pastebin::Schema::Pastebin;

use strict;
use warnings;
use base 'DBIx::Class';
__PACKAGE__->load_components("Core");
__PACKAGE__->table("pastebin");
__PACKAGE__->add_columns(
  "id",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 12 },
  "text",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => 65535,
  }
);
__PACKAGE__->set_primary_key("id");

1;
