package Foorum::Schema::PollOption;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('poll_option');
__PACKAGE__->add_columns(qw/
    option_id poll_id text vote_no
/);
__PACKAGE__->set_primary_key('option_id');
__PACKAGE__->belong_to('poll' => 'Foorum::Schema::Poll', { 'foreign.poll_id' => 'self.poll_id' } );
__PACKAGE__->has_many('pollresult' => 'Foorum::Schema::PollResult', { 'foreign.option_id' => 'self.option_id' } );

1;