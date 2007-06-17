package Foorum::Schema::ScheduledEmail;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('scheduled_email');
__PACKAGE__->add_columns(
    qw/
        email_id email_type processed from_email to_email subject plain_body html_body time
        /
);
__PACKAGE__->set_primary_key(qw/email_id/);

1;
