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
requires 'Cache::Memcached';
requires 'MIME::Entity';
requires 'Mail::Mailer';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Cache::Memcached';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Plugin::Session::DynamicExpiry';
requires 'Catalyst::Plugin::FormValidator::Simple';
requires 'Catalyst::Plugin::Captcha';
requires 'Catalyst::Plugin::I18N';
requires 'Template::Plugin::FillInForm';
requires 'Template::Plugin::Date';
requires 'Template::Plugin::String::Compare';
requires 'File::Remove';
requires 'Email::Obfuscate';
requires 'Locale::Country::Multilingual';
requires 'YAML::Syck';
requires 'File::Slurp';
requires 'Net::IP::Match::Regexp';
requires 'Net::CIDR::Lite';
requires 'TheSchwartz';

recommends 'HTML::BBCode' => '2.00';
recommends 'Text::Textile';
recommends 'Catalyst::Model::DBIC::Schema::QueryLog';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
