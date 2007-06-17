package Foorum::Model::DBIC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Foorum::Schema',
    connect_info => [
        Foorum->config->{dsn},
        Foorum->config->{dsn_user},
        Foorum->config->{dsn_pwd},
        { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
    ],
);

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
