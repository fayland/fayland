package Foorum::Controller::Admin::User;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use Foorum::Utils qw/get_page_no_from_url/;

sub auto : Private {
    my ($self, $c) = @_;

    # only administrator is allowed. site moderator is not allowed here
    unless ( $c->model('Policy')->is_admin( $c, 'site' ) ) {
        $c->forward('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
        return 0;
    }
    return 1;
}

sub default : Private {
    my ($self, $c) = @_;
    
    my $page = get_page_no_from_url($c->req->path);
    my $rs = $c->model('DBIC::User')->search( { }, {
        order_by => 'user_id',
        page => $page,
        rows => 20,
    } );
    
    $c->stash( {
        template => 'admin/user/index.html',
        users    => [ $rs->all ],
        pager    => $rs->pager,
        url_prefix => '/admin/user',
    } );
}

sub edit : Local {
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'admin/user/edit.html';
    
    my $user_id = $c->req->param('user_id');
    my $username = $c->req->param('username');
    my @query_cols;
    if ($user_id) {
        @query_cols = ('user_id', $user_id);
    } elsif ($username) {
        @query_cols = ('username', $username);
    } else {
        return;
    }
    my $user = $c->model('DBIC::User')->find( { @query_cols } );
    return $c->stash->{error} = 'NO_RECORD' unless ($user);
    
    unless ($c->req->method eq 'POST') {
        return $c->stash->{user} = $user;
    } else {
        my @columns = $user->columns;
        my @update_cols;
        my $query = $c->req->params;
        foreach my $key (keys %$query) {
            # DONOT update the user_id here
            next if ($key eq 'user_id');
            # user has this column
            if (grep { $_ eq $key } @columns) {
                if ($key eq 'username') {
                    # validate
                    my $ERROR_USERNAME = $c->model('Profile')->check_valid_username($c, $query->{username});
                    next if ($ERROR_USERNAME);
                }
                push @update_cols, ($key, $query->{$key});
            }
        }
        $user->update( { @update_cols } );
        # update session
        if ($c->user->user_id == $c->req->param('user_id')) {
            $c->session->{__user} = $c->req->param('username');
        }
        return $c->res->redirect('/admin?m=OK');
    }
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;