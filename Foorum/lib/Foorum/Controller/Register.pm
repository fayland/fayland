package Foorum::Controller::Register;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use Digest ();

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->stash->{template} = 'register/index.html';
    
    return unless ($c->req->param('process'));
    
    # execute validation.
    $c->form(
        username  => [[ 'DBIC_UNIQUE', $c->model('DBIC')->resultset('User'), 'username' ], qw/NOT_BLANK ASCII/,       [qw/LENGTH 4 20/] ],
        password  => [qw/NOT_BLANK/,             [qw/LENGTH 6 20/] ],
        email     => [qw/NOT_BLANK EMAIL_LOOSE/, [qw/LENGTH 5 20/], [ 'DBIC_UNIQUE', $c->model('DBIC')->resultset('User'), 'email' ] ],
        { passwords => ['password', 'confirm_password'] } => ['DUPLICATION'],
    );

    return if ($c->form->has_error);
    
    # password
    my $password = $c->req->param('password');
    my $d = Digest->new( $c->config->{authentication}->{dbic}->{password_hash_type} );
    $d->add($password);
    my $computed = $d->digest;
    
    my @extra_columns;
    if ($c->config->{email}->{on}) {
    	my $active_code = int(rand(999999));
    	@extra_columns = ( active_code => $active_code );
    	
    	# TODO, mail send
    }
    
    $c->model('DBIC')->resultset('User')->create({
        username  => $c->req->param('username'),
        password  => $computed,
        email     => $c->req->param('email'),
        register_on => DateTime->now,
        register_ip => $c->req->address,
        has_actived => 0,
        @extra_columns,
    });
    
    $c->forward('/print_message', [ { 
        msg => 'register success!',
        uri => $c->session->{url_referer} || '/',
    } ] );
}

sub import_contacts : Local {
    my ($self, $c) = @_;
    
    my $email = $c->user->email if ($c->user_exists);
    
    unless ($c->config->{email}->{import}) {
        $c->detach('/print_message', [ { 
            msg => 'It\'s disabled.',
        } ] );
    }
    
    $c->stash( {
        template => 'register/import_contacts.html',
        email    => $email,
    } );
    return unless ($c->req->param('submit'));
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
