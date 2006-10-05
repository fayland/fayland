package Foorum::Schema::PollResult;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('poll_result');
__PACKAGE__->add_columns(qw/
    option_id poll_id poster_id poster_ip
/);
__PACKAGE__->set_primary_key(qw/option_id poll_id poster_id/);
__PACKAGE__->belongs_to('poll' => 'Foorum::Schema::Poll', { 'foreign.poll_id' => 'self.poll_id' } );
__PACKAGE__->belongs_to('option' => 'Foorum::Schema::PollOption', { 'foreign.option_id' => 'self.option_id' } );

1;