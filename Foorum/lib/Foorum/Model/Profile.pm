package Foorum::Model::Profile;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub check_valid_username {
    my ($self, $c, $username) = @_;
    
    my @reserved_username = @{ $c->config->{reserved_username} };
    
    for ($username) {
        return 'HAS_BLANK' if (/\s/);
        return 'HAS_SPECAIL_CHAR' unless (/^[A-Za-z0-9\_\-]+/s);
        if (grep { $username eq $_ } @reserved_username) { # $_$
            return 'HAS_RESERVED';
        }
    }
    return;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
