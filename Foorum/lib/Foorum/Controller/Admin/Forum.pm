package Foorum::Controller::Admin::Forum;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

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
    
    my @forums = $c->model('DBIC')->resultset('Forum')->search( { }, {
        order_by => 'me.forum_id',
        prefetch => ['last_post'],
    } )->all;
    
    $c->stash->{forums} = \@forums;
    $c->stash->{template} = 'admin/forum/index.html';
}

sub create : Local {
    my ( $self, $c ) = @_;
    
    $c->stash( {
        template => 'admin/forum/create.html',
    } );
    
    return unless ($c->req->param('submit'));
    
    # do we trust everything typed by admin?
    # NO.
    
    $c->form(
        name => [qw/NOT_BLANK/,             [qw/LENGTH 1 40/] ],
#        description  => [qw/NOT_BLANK/ ],
    );
    return if ($c->form->has_error);
    
    my $name  = $c->req->param('name');
    my $admin = $c->req->param('admin');
    my $description = $c->req->param('description');
    my $moderators  = $c->req->param('moderators');
    my $private = $c->req->param('private');

    # validate the admin and moderators first
    my $admin_user = $c->model('DBIC::User')->find( { username => $admin } );
    unless ($admin_user) {
        return $c->set_invalid_form( admin => 'ADMIN_NONEXISTENCE' );
    }
    my @moderators = split(/\s*\,\s*/, $moderators);
    my @moderator_users;
    foreach (@moderators) {
        next if ($_ eq $admin); # avoid the same man
        last if (scalar @moderator_users > 2); # only allow 3 moderators at most
        my $moderator_user = $c->model('DBIC::User')->find( { username => $_ } );
        unless ($moderator_user) {
            $c->stash->{non_existence_user} = $_;
            return $c->set_invalid_form( moderators => 'ADMIN_NONEXISTENCE' );
        }
        push @moderator_users, $moderator_user;
    }
    
    # insert data into table.
    my $policy = ($private == 1)?'private':'public';
    my $forum = $c->model('DBIC::Forum')->create( {
        name => $name,
        description => $description,
        type => 'classical',
        policy => $policy,
    } );
    $c->model('DBIC::UserRole')->create( {
        user_id => $admin_user->user_id,
        role    => 'admin',
        field   => $forum->forum_id,
    } );
    foreach (@moderator_users) {
        $c->model('DBIC::UserRole')->create( {
            user_id => $_->user_id,
            role    => 'moderator',
            field   => $forum->forum_id,
        } );
    }
    # mkdir for upload image
    mkdir($c->path_to('root', 'upload', $forum->forum_id), '0777');
    chmod 0777, $c->path_to('root', 'upload', $forum->forum_id);
    
    $c->stash( {
        is_ok => 1,
        forum => $forum,
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;