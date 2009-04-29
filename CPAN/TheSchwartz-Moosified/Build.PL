use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'TheSchwartz::Moosified',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/TheSchwartz/Moosified.pm',
    build_requires => {
        'Test::More' => 0,
        'Moose' => '0.57',
        'DBI' => 0,
        'Scalar::Util' => 0,
        'Storable' => '2.18',
    },
    add_to_cleanup      => [ 'TheSchwartz-Moosified-*' ],
    create_makefile_pl => 'traditional',
    meta_merge     => {
        resources => {
          repository  => 'http://github.com/fayland/fayland/tree/master'
        }
    },
);

$builder->create_build_script();
