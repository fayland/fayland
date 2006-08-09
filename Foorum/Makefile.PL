use inc::Module::Install;

name 'Foorum';
all_from 'lib\Foorum.pm';

requires Catalyst => '5.64';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
