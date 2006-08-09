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
	SubRequest
	FormValidator::Simple
/;

our $VERSION = '0.01';

__PACKAGE__->setup;

1;
