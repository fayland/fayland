use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'CatalystX::Foorum',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/CatalystX/Foorum.pm',
    build_requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'CatalystX-Foorum-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
