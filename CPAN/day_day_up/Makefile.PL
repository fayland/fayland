use inc::Module::Install;

name            ('DayDayUp');
author          ('Fayland Lam<fayland@gmail.com>');
abstract        ('DayDayUp - good good study, day day up');
license         ('perl');
version_from    ('lib/DayDayUp.pm');

requires 'Mojo'     => '0.8009';
requires 'Moose'    => '0.57';
requires 'Template' => '2.20';
requires 'MojoX::Renderer::TT' => 0;
requires 'DBD::SQLite' => 0;
requires 'YAML'	   => 0;

tests ( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );

auto_install;
WriteAll;
