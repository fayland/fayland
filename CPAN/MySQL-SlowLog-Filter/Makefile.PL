use inc::Module::Install;

name     'MySQL-SlowLog-Filter';
all_from 'lib/MySQL/SlowLog/Filter.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

requires 'Time::Local';
requires 'DBI';
requires 'DBD::SQLite';
requires 'File::Slurp';

build_requires 'Test::More';

auto_install;

WriteAll;

