use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Zorpia::Upload',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/WWW/Zorpia/Upload.pm',
    create_makefile_pl  => 'traditional',
    build_requires => {
        'Test::More' => 0,
        'File::Spec' => 0,
        'WWW::Mechanize' => 0,
    },
    add_to_cleanup      => [ 'WWW-Zorpia-Upload-*' ],
);

$builder->create_build_script();
