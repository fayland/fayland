package CatalystX::Pastebin::Model::DBIC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CatalystX::Pastebin::Schema',
    connect_info => [
        'dbi:SQLite:pastebin.sqlite',
        
    ],
);

=head1 NAME

CatalystX::Pastebin::Model::DBIC - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<CatalystX::Pastebin>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<CatalystX::Pastebin::Schema>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
