package Foorum::Controller::Profile;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use Digest ();

sub profile : Regex('^u/(\w{6,20})$') {
    my ( $self, $c ) = @_;
    
    my $username = $c->req->snippets->[0];
    
    my $user = $c->model('DBIC')->resultset('User')->search( { username => $username } )->first;
    
    if ($user) {
        $c->stash->{user} = $user;
        $c->stash->{template} = 'user/profile.html';
    } else {
        $c->forward('/print_error', [ 'ERROR_USER_NON_EXIST' ] );
    }
}

sub edit : Local {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    $c->stash->{template} = 'user/profile/edit.html';
    
    unless ($c->req->param('submit')) {
        if ($c->user->birthday and $c->user->birthday =~ /^(\d+)\-(\d+)\-(\d+)$/) {
            $c->stash( {
                year  => $1,
                month => $2,
                day   => $3,
            } );
        }
        return;
    }
    # TODO
    $c->form(
        gender   => [ ['REGEX', qr/^(M|F)?$/ ] ],
        { birthday  => ['year', 'month', 'day'] } => ['DATE'],
        homepage => [ 'HTTP_URL' ],
        nickname => [ qw/NOT_BLANK/, [qw/LENGTH 4 20/] ],
    );
    return if ($c->form->has_error);

    my $birthday = $c->req->param('year') . '-' . $c->req->param('month') . '-' . $c->req->param('day');

    $c->user->update( {
        nickname => $c->req->param('nickname') || $c->user->username,
        gender   => $c->req->param('gender') || '',
        birthday => $birthday,
        homepage => $c->req->param('homepage') || '',
    } );
    
    $c->res->redirect('/u/' . $c->user->username);
}

sub change_password : Local {
    my ( $self, $c ) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    $c->stash->{template} = 'user/profile/change_password.html';
    
    return unless ($c->req->param('process'));

    # check the password typed in is correct
    my $password = $c->req->param('password');
    my $d = Digest->new( $c->config->{authentication}->{dbic}->{password_hash_type} );
    $d->add($password);
    my $computed = $d->digest;
    if ($computed ne $c->user->password) {
        $c->set_invalid_form( password => 'WRONG_PASSWORD' );
        return;
    }
    
    # execute validation.
    $c->form(
        new_password => [qw/NOT_BLANK/,             [qw/LENGTH 6 20/] ],
        { passwords  => ['new_password', 'confirm_password'] } => ['DUPLICATION'],
    );
    return if ($c->form->has_error);
    
    # encrypted the new password
    my $new_password = $c->req->param('new_password');
    $d->reset;
    $d->add($new_password);
    my $new_computed = $d->digest;

    $c->user->update( {
        password => $new_computed,
    } );
    
    $c->res->body('ok');
}

sub change_email : Local {
    my ( $self, $c ) = @_;

    return $c->res->redirect('/login') unless ($c->user_exists);

    $c->stash->{template} = 'user/profile/change_email.html';
    
    return unless ($c->req->param('process'));
    
    my $email = $c->req->param('email');
    if ($email eq $c->user->email) {
        $c->set_invalid_form( email => 'EMAIL_DUPLICATION' );
        return;
    }
    
    # execute validation.
    $c->form(
        email     => [qw/NOT_BLANK EMAIL_LOOSE/, [qw/LENGTH 5 20/], [ 'DBIC_UNIQUE', $c->model('DBIC')->resultset('User'), 'email' ] ],
    );
    return if ($c->form->has_error);
    
    my @extra_columns;
    if ($c->config->{email}->{on}) {
    	my $active_code = int(rand(999999));
    	@extra_columns = ( active_code => $active_code, has_actived => 0 );
    	
    	# TODO, mail send
    }
    
    $c->user->update( {
        email => $email,
        @extra_columns,
    } );
    
    $c->res->body('ok');
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
