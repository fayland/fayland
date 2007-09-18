package Foorum::Schema::MessageUnread;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("message_unread");
__PACKAGE__->add_columns(
  "message_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "user_id",
  { data_type => "INT", default_value => "", is_nullable => 0, size => 11 },
);


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 18:29:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jAd/Var5nm82Ra9yPfIPuA




# You can replace this text with custom content, and it will be preserved on regeneration
1;
