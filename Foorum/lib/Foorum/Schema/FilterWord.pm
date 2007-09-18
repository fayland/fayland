package Foorum::Schema::FilterWord;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("filter_word");
__PACKAGE__->add_columns(
  "word",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 64 },
  "type",
  {
    data_type => "ENUM",
    default_value => "username_reserved",
    is_nullable => 1,
    size => 19,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 18:48:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u4P//tZKs+Rq6wdxBUBLlQ






# You can replace this text with custom content, and it will be preserved on regeneration
1;
