use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'XML::HARef',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/XML/HARef.pm',
    build_requires => {
        'Test::More'  => 0,
        'Scalar::Util' => 0,
        'XML::Writer' => 0,
    },
    add_to_cleanup      => [ 'XML-HARef-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
