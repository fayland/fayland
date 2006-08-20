package Foorum::Controller::Admin::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub email : Local {
    my ( $self, $c ) = @_;
    
    my $email_setting = $c->config->{email};
    
    my $result = $c->email(
        header => [
            From    => 'fayland@gmail.com',
            To      => 'notfour@163.com',
            Subject => 'Test Foorum Email'
        ],
        body => 'OK',
    );
    
    $c->res->body(Dumper($email_setting) . ' AND ' . Dumper($result));
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;