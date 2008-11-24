use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Padre::Plugin::Validator',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Padre/Plugin/Validator.pm',
    build_requires => {
        'Test::More' => 0,
        'Padre'		 => '0.18',
        'XML::XPath' => 0,
        'WebService::Validator::HTML::W3C' => 0,
        'WebService::Validator::CSS::W3C'  => 0,
    },
    add_to_cleanup      => [ 'Padre-Plugin-Validator-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
