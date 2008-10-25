use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::HTTP::Session',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Catalyst/Plugin/HTTP/Session.pm',
    build_requires => {
        'Test::More' => 0,
        'HTTP::Session' => 0,
        'Catalyst'   => 0,
        'MooseX::Emulate::Class::Accessor::Fast' => 0,
        'CGI'        => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-HTTP-Session-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
