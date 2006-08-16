package Foorum;

use strict;
use warnings;

use Catalyst qw/
	-Debug
	StackTrace
	ConfigLoader
	Authentication
	Authentication::Store::DBIC
	Authentication::Credential::Password
	Session
	Session::Store::DBIC
	Session::State::Cookie
	Static::Simple
	Prototype
	FormValidator::Simple
	Scheduler
/;

our $VERSION = '0.01';

__PACKAGE__->setup;

1;
