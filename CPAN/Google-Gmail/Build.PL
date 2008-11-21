use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Google::Gmail',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Google/Gmail.pm',
    build_requires => {
        'Test::More' => 0,
        'Crypt::SSLeay' => 0,
    },
    add_to_cleanup      => [ 'Google-Gmail-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
