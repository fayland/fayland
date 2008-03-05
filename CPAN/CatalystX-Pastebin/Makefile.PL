use inc::Module::Install;

name 'CatalystX-Pastebin';
all_from 'lib\CatalystX\Pastebin.pm';

requires 'Catalyst::Runtime' => '5.7012';
requires 'DBIx::Class';
requires 'DBD::SQLite';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
