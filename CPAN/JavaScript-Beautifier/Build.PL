use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'JavaScript::Beautifier',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/JavaScript/Beautifier.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'JavaScript-Beautifier-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
