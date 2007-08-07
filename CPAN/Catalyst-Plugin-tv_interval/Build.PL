use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::tv_interval',
    license             => 'perl',
    dist_author         => 'Fayland <fayland@gmail.com>',
    dist_version_from   => 'lib/Catalyst/Plugin/tv_interval.pm',
    create_makefile_pl  => 'traditional',
    build_requires => {
        'Test::More' => 0,
        'Time::HiRes' => 0,
        'Catalyst' => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-tv_interval-*' ],
);

$builder->create_build_script();
