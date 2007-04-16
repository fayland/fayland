package Foorum::Schema::FilterWord;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('filter_word');
__PACKAGE__->add_columns(qw/
    word type
/);
__PACKAGE__->set_primary_key(qw/word type/);

1;