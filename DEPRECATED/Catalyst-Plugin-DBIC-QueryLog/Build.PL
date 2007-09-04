use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::DBIC::QueryLog',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail>',
    dist_version_from   => 'lib/Catalyst/Plugin/DBIC/QueryLog.pm',
    create_makefile_pl  => 'traditional',
    build_requires => {
        'Test::More' => 0,
        'Catalyst' => 0,
        'DBIx::Class::QueryLog' => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-DBIC-QueryLog-*' ],
);

$builder->create_build_script();
