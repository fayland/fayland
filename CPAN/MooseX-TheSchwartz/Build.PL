use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MooseX::TheSchwartz',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/MooseX/TheSchwartz.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'MooseX-TheSchwartz-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
