use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Padre::Plugin::WordStats',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Padre/Plugin/WordStats.pm',
    build_requires => {
        'Test::More' => 0,
        'Padre'		 => '0.15',
    },
    add_to_cleanup      => [ 'Padre-Plugin-WordStats-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
