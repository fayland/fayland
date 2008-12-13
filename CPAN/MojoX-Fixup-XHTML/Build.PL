use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MojoX::Fixup::XHTML',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/MojoX/Fixup/XHTML.pm',
    build_requires => {
        'Test::More' => 0,
        'Mojo'		 => '0.9',
        'HTTP::Headers'   => 0,
        'HTTP::Negotiate' => 0,
    },
    add_to_cleanup      => [ 'MojoX-Fixup-XHTML-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
