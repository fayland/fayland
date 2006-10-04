package Foorum::Controller::Profile;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Foorum::Utils qw/generate_random_word/;
use Digest ();

sub begin : Private {
    my ($self, $c) = @_;

    if ($c->action ne 'profile/forget_password') {
        $c->stash( {
            no_online_view => 1,
        } );
    }
}

sub profile : Regex('^u/(\w{6,20})$') {
    my ( $self, $c ) = @_;
    
    my $username = $c->req->snippets->[0];
    
    my $user = $c->model('DBIC')->resultset('User')->single( { username => $username } );
    
    if ($user) {
        $c->stash->{user} = $user;
        $c->stash->{template} = 'user/profile.html';
    } else {
        $c->forward('/print_error', [ 'ERROR_USER_NON_EXSIT' ] );
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
    
    my $birthday = $c->req->param('year') . '-' . $c->req->param('month') . '-' . $c->req->param('day');
    my (@extra_valid, @extra_insert);
    if (length($birthday) > 2) { # is not --
        @extra_valid  = ( { birthday  => ['year', 'month', 'day'] } => ['DATE'] );
        @extra_insert = ( birthday => $birthday );
    }
    
    $c->form(
        gender   => [ ['REGEX', qr/^(M|F)?$/ ] ],
        @extra_valid,
        homepage => [ 'HTTP_URL' ],
        nickname => [ qw/NOT_BLANK/, [qw/LENGTH 4 20/] ],
    );
    return if ($c->form->has_error);

    $c->user->update( {
        nickname => $c->req->param('nickname') || $c->user->username,
        gender   => $c->req->param('gender') || '',
        @extra_insert,
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

sub forget_password : Local {
    my ($self, $c) = @_;

    $c->detach('/print_error', [ 'ERROR_EMAIL_OFF' ] ) unless ($c->config->{mail}->{on});
    
    $c->stash->{template} = 'user/profile/forget_password.html';
    return unless ($c->req->param('submit'));
    
    my $username = $c->req->param('username');
    my $email    = $c->req->param('email');
    
    my $user = $c->model('DBIC::User')->find( { username => $username } );
    return $c->stash->{ERROR_NOT_SUCH_USER} = 1 unless ($user);
    return $c->stash->{ERROR_NOT_MATCH} = 1 if ($user->email ne $email);
    
    # create a random password
    my $random_password = &generate_random_word(10);
    my $d = Digest->new( $c->config->{authentication}->{dbic}->{password_hash_type} );
    $d->add($random_password);
    my $computed = $d->digest;
    
    # send email
    $c->model('Email')->send_forget_password($c, $email, $username, $random_password);
    $c->log->debug("PASSWORD: $random_password");
    $user->update( { password => $computed } );
    $c->res->redirect('/login');
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
    	my $active_code = &generate_random_word(10);
    	@extra_columns = ( active_code => $active_code, has_actived => 0 );
    	
    	# send activation code
    	$c->model('Email')->send_activation($c, $email, $c->user->username, $active_code);
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
