use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Module::Install::Acme::PlayCode',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Module/Install/Acme/PlayCode.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Module-Install-Acme-PlayCode-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
