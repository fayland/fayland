use inc::Module::Install;

name     'MooseX-Dumper';
all_from 'lib/MooseX/Dumper.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl5';

requires 'Moose' => '0.57';
requires 'MooseX::Traits';
requires 'Data::Dumper';
requires 'Perl::Tidy';
requires 'Text::InHTML';

build_requires 'Test::More';

auto_install;

WriteAll;

