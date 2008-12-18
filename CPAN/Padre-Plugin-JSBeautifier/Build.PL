use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Padre::Plugin::JSBeautifier',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Padre/Plugin/JSBeautifier.pm',
    build_requires => {
        'Test::More' => 0,
        'Padre'      => '0.18',
        'JavaScript::Beautifier' => '0.03',
    },
    add_to_cleanup      => [ 'Padre-Plugin-JSBeautifier-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
