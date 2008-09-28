use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Contact',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/WWW/Contact.pm',
    build_requires => {
        'Test::More' => 0,
        'Moose'      => 0,
        'WWW::Mechanize' => 0,
    },
    add_to_cleanup      => [ 'WWW-Contact-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
