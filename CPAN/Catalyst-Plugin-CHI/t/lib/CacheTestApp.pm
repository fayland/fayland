#!/usr/bin/perl

package CacheTestApp;

use strict;
use warnings;

use Catalyst qw/
    CHI
/;

__PACKAGE__->config->{CHI} = {
    driver => 'Memory',
};

__PACKAGE__->setup;

__PACKAGE__;

__END__
