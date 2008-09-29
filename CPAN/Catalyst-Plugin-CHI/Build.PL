use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::CHI',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Catalyst/Plugin/CHI.pm',
    build_requires => {
        'Test::More' => 0,
        'Catalyst'   => 0,
        'CHI'        => 0,
        'Class::Data::Inheritable' => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-CHI-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
