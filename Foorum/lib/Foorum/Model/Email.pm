package Foorum::Model::Email;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub send_activation {
    my ($self, $c, $email, $username, $active_code) = @_;
    
    my $email_body = $c->view('TT')->render($c, $c->stash->{lang} . '/email/activation.html', {
        no_wrapper => 1,
        username => $username,
        active_code => $active_code,
    } );
    
    $c->model('DBIC')->resultset('ScheduledEmail')->create( {
        email_type => 'activation',
        from_email => $c->config->{mail}->{from_email},
        to_email   => $email,
        subject    => 'Your Activation Code In ' . $c->config->{name},
        plain_body => $email_body,
        time       => \'NOW()',
        processed  => 'N',
    } );
}

sub send_forget_password {
    my ($self, $c, $email, $username, $password) = @_;

    my $email_body = $c->view('TT')->render($c, $c->stash->{lang} . '/email/forget_password.html', {
        no_wrapper => 1,
        username => $username,
        password => $password,
    } );
    
    $c->model('DBIC')->resultset('ScheduledEmail')->create( {
        email_type => 'forget_password',
        from_email => $c->config->{mail}->{from_email},
        to_email   => $email,
        subject    => 'Your Password For ' . $username . ' In ' . $c->config->{name},
        plain_body => $email_body,
        time       => \'NOW()',
        processed  => 'N',
    } );
}    

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
