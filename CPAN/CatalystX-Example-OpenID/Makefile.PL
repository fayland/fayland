# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'CatalystX-Example-OpenID';
all_from 'lib\CatalystX\Example\OpenID.pm';

requires 'Catalyst::Runtime' => '5.7015';
requires 'parent';

requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::File';

requires 'Catalyst::Plugin::Authentication' => '0.10008';
requires 'Catalyst::Authentication::Credential::OpenID';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
