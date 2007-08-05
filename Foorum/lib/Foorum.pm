package Foorum;

use strict;
use warnings;

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Cache::Memcached
    Authentication
    Authentication::Store::Hash
    Authentication::Credential::Password
    Session::DynamicExpiry
    Session
    Session::Store::DBIC
    Session::State::Cookie
    I18N
    PageCacheWithI18N
    FormValidator::Simple
    Captcha
    FoorumUtils
    /;

#	

use vars qw/$VERSION/;
$VERSION = '0.06';

__PACKAGE__->config( { VERSION => $VERSION } );

__PACKAGE__->setup();

__PACKAGE__->log->levels('error', 'fatal'); # for real server
if( __PACKAGE__->config->{debug_mode} ) {
    
    __PACKAGE__->log->enable('debug', 'info', 'warn'); # for developer server
    {
        # these code are copied from Catalyst.pm setup_log
        no strict 'refs';
        my $class = __PACKAGE__;
        *{"$class\::debug"} = sub { 1 };
    }
    
    my @extra_plugins = qw/ StackTrace DBIC::Schema::Profiler /;
    __PACKAGE__->setup_plugins( [ @extra_plugins ] );
}

1;
