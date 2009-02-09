use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::Config::YAML::XS',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Catalyst/Plugin/Config/YAML/XS.pm',
    build_requires => {
        'Test::More' => 0,
        'Catalyst' => 0,
        'MRO::Compat' => 0,
    	'YAML::XS' => 0,
    	'Path::Class' => 0, 
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-Config-YAML-XS-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
