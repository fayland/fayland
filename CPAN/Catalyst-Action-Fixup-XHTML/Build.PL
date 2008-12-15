use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Action::Fixup::XHTML',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Catalyst/Action/Fixup/XHTML.pm',
    build_requires => {
        'Test::More' => 0,
        'HTTP::Negotiate' => 0,
        'Catalyst::Runtime' => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Action-Fixup-XHTML-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
