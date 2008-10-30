package CatalystX::Example::OpenID::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Data::Dumper;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

sub default :Path {
    my ( $self, $c ) = @_;
    
    my $claimed_uri = $c->req->params->{openid_identifier};
    if ( $claimed_uri ) {
        $c->authenticate({openid_identifier => $claimed_uri});
    }

    $c->log->debug(Dumper(\$c->session));    
    $c->response->content_type("text/html");
    if ( $c->user_exists ) {
        $c->res->body(Dumper(\$c->user->obj));
    } else {
        $c->res->body(<<HTML);
<form method='post'>
Please type your OpenID: <input type='text' name='openid_identifier' />
<input type='submit' />
</form>
HTML

    }
}
sub end : Private {
    my ( $self, $c ) = @_;
    
    return 1;
}


1;
__END__

=head1 NAME

CatalystX::Example::OpenID::Controller::Root - Root Controller for CatalystX::Example::OpenID

=head1 DESCRIPTION

[enter your description here]

=head1 AUTHOR

Fayland Lam < fayland at cpan dot com >

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
