package Foorum::Controller::Register;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use Digest ();
use Foorum::Utils qw/generate_random_word/;
use Data::Dumper;

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->stash->{template} = 'register/index.html';
    
    return unless ($c->req->param('process'));
    
    # execute validation.
    
    # username
    my $username = $c->req->param('username');
    my $ERROR_USERNAME = &check_valid_username($self, $c, $username);
    if ($ERROR_USERNAME) {
        $c->set_invalid_form( username => $ERROR_USERNAME );
        return;
    }
    
    # TODO, DBIC_UNIQUE should be LIKE
    $c->form(
        username  => [[ 'DBIC_UNIQUE', $c->model('DBIC')->resultset('User'), 'username' ], qw/NOT_BLANK/,       [qw/LENGTH 4 20/] ],
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
    if ($c->config->{mail}->{on}) {
    	my $active_code = &generate_random_word(10);
    	@extra_columns = ( active_code => $active_code, has_actived => 0, );
    	
    	# TODO, mail send
    	my $email_body = $c->view('NoWrapperTT')->render($c, 'email/activation.html', {
            additional_template_paths => [ $c->path_to('templates', $c->stash->{lang}) ],
            username => $username,
            active_code => $active_code,
        } );
        
    } else {
        @extra_columns = ( has_actived => 1, );
    }
    
    $c->model('DBIC')->resultset('User')->create({
        username  => $username,
        nickname  => $username,
        password  => $computed,
        email     => $c->req->param('email'),
        register_on => DateTime->now,
        register_ip => $c->req->address,
        @extra_columns,
    });
    
    # redirect or forward
    if ($c->config->{email}->{on}) {
        $c->res->redirect("/register/activation/$username"); # to activation
    } else {
        $c->forward('/print_message', [ { 
            msg => 'register success!',
            uri => $c->session->{url_referer} || '/',
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
    
    my $email = $c->user->email if ($c->user_exists);
    
    unless ($c->config->{mail}->{import}) {
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

=item check_valid_username

check a "username" is valid or not

=cut

sub check_valid_username : Private {
    my ($self, $c, $username) = @_;
    
    my @reserved_username = @{ $c->config->{reserved_username} };
    
    for ($username) {
        return 'HAS_BLANK' if (/\s/);
        return 'HAS_SPECAIL_CHAR' if (/[\a\f\n\e\0\r\t\`\~\!\@\#\$\%\^\&\*\(\)\+\=\\\{\}\;\'\:\"\,\.\/\<\>\?\[\]]/is);
        if (grep(/^$username$/, @reserved_username)) { # $_$
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
