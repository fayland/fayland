use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Acme::CPANAuthors::Chinese',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Acme/CPANAuthors/Chinese.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Acme-CPANAuthors-Chinese-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
