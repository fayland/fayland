package Foorum::Schema::PollOption;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("poll_option");
__PACKAGE__->add_columns(
  "option_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "poll_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "text",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "vote_no",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 6 },
);
__PACKAGE__->set_primary_key("option_id");


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-09-18 19:46:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JLj5Np+IUQnUemcIqwJEvw










# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->belongs_to(
    'poll' => 'Foorum::Schema::Poll',
    { 'foreign.poll_id' => 'self.poll_id' }
);
__PACKAGE__->has_many(
    'results' => 'Foorum::Schema::PollResult',
    { 'foreign.option_id' => 'self.option_id' }
);
1;
