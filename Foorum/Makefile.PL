use inc::Module::Install;

name 'Foorum';
all_from 'lib\Foorum.pm';

requires 'Template';
requires 'DBIx::Class';
requires 'Catalyst' => '5.64';
requires 'Digest';
requires 'DateTime';
requires 'Date::Manip';
requires 'Data::Dumper';
requires 'Cache::Memcached';
requures 'Email::Send' => '2.180';
requires 'XML::RSS';
requires 'Catalyst::Plugin::Prototype';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Store::DBIC';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Session::DynamicExpiry';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Cache::Memcached';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Plugin::FormValidator::Simple';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::Email';
requires 'Catalyst::Plugin::Captcha';
requires 'Template::Plugin::FillInForm';
requires 'Template::Plugin::Dumper';
requires 'Template::Plugin::Date';
requires 'Template::Plugin::HTML::BBCode';
requires 'Template::Plugin::String::Compare';
requires 'File::Remove';
requires 'IP::QQWry';
requires 'Email::Obfuscate';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
