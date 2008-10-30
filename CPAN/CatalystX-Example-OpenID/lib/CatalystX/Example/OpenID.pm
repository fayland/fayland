package CatalystX::Example::OpenID;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use File::Spec;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/-Debug
                Authentication
                Session
                Session::State::Cookie
                Session::Store::File
                /;
our $VERSION = '0.01';

# Configure the application. 

__PACKAGE__->config(
    name => 'CatalystX::Example::OpenID',
    session => {
        storage => File::Spec->tmpdir(),
    },
    "Plugin::Authentication" => {
        default_realm => "openid",
        realms => {
            openid => {
                consumer_secret => "Don't bother setting",
                ua_class => "LWPx::ParanoidAgent",
                ua_args => {
                    whitelisted_hosts => ['127.0.0.1', 'localhost', qr/\.myopenid\.com/],
                },
                credential => {
                    class => "OpenID",
                    store => {
                        class => "OpenID",
                    },
                }
            }
        }
    }
);

# Start the application
__PACKAGE__->setup();

1;
__END__

=head1 NAME

CatalystX::Example::OpenID - Catalyst based application

=head1 SYNOPSIS

    script/catalystx_example_openid_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<CatalystX::Example::OpenID::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Fayland Lam < fayland at cpan dot com >

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
