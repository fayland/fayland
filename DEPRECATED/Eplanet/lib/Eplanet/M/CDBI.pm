package Eplanet::M::CDBI;

use strict;
#use base 'Catalyst::Model::CDBI::CRUD';
use base 'Catalyst::Model::CDBI';
#use Class::DBI::Plugin::RetrieveAll;

__PACKAGE__->config(
        dsn           => Eplanet->config->{dsn},
        password      => Eplanet->config->{dsn_pwd},
        user          => Eplanet->config->{dsn_user},
        options       => { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
        relationships => 1,
);

#Eplanet::M::CDBI::Cms->has_a(cms_cat_id => 'Eplanet::M::CDBI::Category');

1;
