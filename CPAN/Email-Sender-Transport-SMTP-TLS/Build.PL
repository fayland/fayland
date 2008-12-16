use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Email::Sender::Transport::SMTP::TLS',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Email/Sender/Transport/SMTP/TLS.pm',
    build_requires => {
        'Test::More' => 0,
        'Email::Sender' => 0,
        'Net::SMTP::TLS' => 0,
    },
    add_to_cleanup      => [ 'Email-Sender-Transport-SMTP-TLS-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
