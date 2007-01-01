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
	PageCache
	FormValidator::Simple
	Email
	Scheduler
	Captcha
	DBIC::Schema::Profiler
/;

our $VERSION = '0.01';

# Log4perl
#use Catalyst::Log::Log4perl;
#__PACKAGE__->log(Catalyst::Log::Log4perl->new('../logger.conf'));

__PACKAGE__->setup;

1;
