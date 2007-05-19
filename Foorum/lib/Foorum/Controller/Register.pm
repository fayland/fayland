package Foorum::Controller::Register;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Digest ();
use Foorum::Utils qw/generate_random_word/;
use Data::Dumper;

sub default : Private {
    my ( $self, $c ) = @_;
    
    if ($c->config->{register}->{closed}) {
        $c->detach('/print_error', [ 'ERROR_REGISTER_CLOSED' ]);
    }
    
    $c->stash->{template} = 'register/index.html';
    return unless ($c->req->method eq 'POST');
    
    # execute validation.
    $c->form(
        username  => [qw/NOT_BLANK/ ],
        password  => [qw/NOT_BLANK/,             [qw/LENGTH 6 20/] ],
        email     => [qw/NOT_BLANK EMAIL_LOOSE/, [qw/LENGTH 5 64/], [ 'DBIC_UNIQUE', $c->model('DBIC::User'), 'email' ] ],
        { passwords => ['password', 'confirm_password'] } => ['DUPLICATION'],
    );
    return if ($c->form->has_error);
    
    # username
    my $username = $c->req->param('username');
    my $ERROR_USERNAME = $c->model('Profile')->check_valid_username($c, $username);
    if ($ERROR_USERNAME) {
        $c->set_invalid_form( username => $ERROR_USERNAME );
        return;
    }
    
    # password
    my $password = $c->req->param('password');
    my $d = Digest->new( $c->config->{authentication}->{dbic}->{password_hash_type} );
    $d->add($password);
    my $computed = $d->digest;
    
    # email
    my $email = $c->req->param('email');
    
    my @extra_columns;
    if ($c->config->{mail}->{on}) {
    	my $active_code = &generate_random_word(10);
    	@extra_columns = ( active_code => $active_code, has_actived => 0, );
    	
    	# send activation code
    	$c->model('Email')->send_activation($c, $email, $username, $active_code);
        
    } else {
        @extra_columns = ( has_actived => 1, );
    }
    
    $c->model('DBIC')->resultset('User')->create({
        username  => $username,
        nickname  => $c->req->param('nickname') || $username,
        password  => $computed,
        email     => $email,
        register_on => \"NOW()",
        register_ip => $c->req->address,
        @extra_columns,
        lang => $c->config->{default_pref_lang},
    });
    
    # redirect or forward
    if ($c->config->{mail}->{on} and $c->config->{register}->{activation}) {
        $c->res->redirect("/register/activation/$username"); # to activation
    } else {
        $c->login($username, $password);
        $c->forward('/print_message', [ { 
            msg => 'register success!',
            url => '/',
        } ] );
    }
}

sub activation : Local {
    my ($self, $c, $username, $active_code) = @_;
    
    $username = $c->req->param('username') unless ($username);
    $active_code = $c->req->param('active_code') unless ($active_code);
    
    $c->stash( {
        template => 'register/activation.html',
        username => $username,
    } );
    return unless ($username and $active_code);
    
    my $user = $c->model('DBIC::User')->find( { username => $username } );
    
    $c->detach('/print_error', [ 'ERROR_USER_NON_EXIST' ] ) unless ($user);
    
    # validator it
    if (!$user->active_code or $user->active_code eq $active_code) {
        $user->update( {
            active_code => '',
            has_actived => 1,
        } );
        # login will be failed since the $user->password is SHA1 Hashed.
        # $c->login( $username, $user->password );
        $c->res->redirect('/profile/edit');
    } else {
        $c->stash->{'ERROR_UNMATCHED'} = 1;
    }
}

sub import_contacts : Local {
    my ($self, $c) = @_;

    return $c->res->redirect('/login') unless ($c->user_exists);
    
    my $email = $c->req->param('email') || $c->user->email;

    $c->stash( {
        template => 'register/import_contacts.html',
        email    => $email,
    } );
    return unless ($c->req->method eq 'POST');
    
    eval("use WWW::Contact;");
    if ($@) {
        $c->detach('/print_error', [ 'ERROR_EMAIL_OFF' ] );
    }
    my $wc = WWW::Contact->new();
    my @contacts = $wc->get_contacts($email, $c->req->param('password'));
   
    my $errStr = $wc->errstr;
    if ($errStr) {
        $c->detach('/print_error', [ $errStr ] );
    }
    
    $c->res->body(Dumper(\@contacts));
}
=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
