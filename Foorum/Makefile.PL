use inc::Module::Install;

name 'Foorum';
all_from 'lib/Foorum.pm';

requires 'Template';
requires 'DBIx::Class';
requires 'Catalyst' => '5.64';
requires 'Digest';
requires 'Switch';
requires 'DateTime';
requires 'File::Path';
requires 'Date::Manip';
requires 'Cache::Memcached';
requires 'XML::RSS';
requires 'MIME::Entity';
requires 'Mail::Mailer';
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Cache::Memcached';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Store::DBIC';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Plugin::Session::DynamicExpiry';
requires 'Catalyst::Plugin::FormValidator::Simple';
requires 'Catalyst::Plugin::Captcha';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::DBIC::Schema::Profiler';
requires 'Template::Plugin::FillInForm';
requires 'Template::Plugin::Date';
requires 'Template::Plugin::HTML::BBCode';
requires 'Template::Plugin::String::Compare';
requires 'File::Remove';
requires 'IP::QQWry';
requires 'Email::Obfuscate';
requires 'Locale::Country::Multilingual';
requires 'FormValidator::Simple::Plugin::DBIC::Unique';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
