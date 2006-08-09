use inc::Module::Install;

name 'Foorum';
all_from 'lib\Foorum.pm';

requires 'Template';
requires 'DBIx::Class';
requires 'Catalyst' => '5.64';
requires 'Digest';
requires 'DateTime';
requires 'Data::Dumper';
requires 'XML::RSS';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Prototype';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Store::DBIC';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Plugin::FormValidator::Simple';
requires 'Template::Plugin::FillInForm';
requires 'Template::Plugin::Dumper';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
