package Foorum;

use strict;
use warnings;

use Catalyst qw/
	-Debug
	ConfigLoader
	Static::Simple
	Cache::Memcached
	Authentication
	Authentication::Store::DBIC
	Authentication::Credential::Password
	Session::DynamicExpiry
	Session
	Session::Store::DBIC
	Session::State::Cookie
	I18N
	PageCacheWithI18N
	FormValidator::Simple
	Captcha
/;

use vars qw/$VERSION/;
$VERSION = '0.04';

__PACKAGE__->config( { VERSION => $VERSION } );

__PACKAGE__->setup;

1;
