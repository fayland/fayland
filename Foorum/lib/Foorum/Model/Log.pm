package Foorum::Model::Log;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub log_path {
    my ($self, $c, $loadtime) = @_;
    
    # sometimes we won't logger path because it expand the table so quickly
    return unless ($c->config->{logger}->{path});
    # but sometimes we want to know which url is causing more than $PATH_LOAD_TIME_MORE_THAN
    return if ($loadtime < $c->config->{logger}->{path_load_time_more_than});
    
    my $path = $c->req->path; $path = ($path) ? substr($path, 0, 255) : 'index'; # varchar(255)
    my $get  = $c->req->uri->query; $get = substr($get, 0, 255) if ($get); # varchar(255)
    my $post = $c->req->body_parameters; $post = (keys %$post) ? substr(Dumper($post), 0, 255) : ''; # varchar(255)
    ($loadtime) = ($loadtime =~ /^(\d{1,5}\.?\d{0,2})/); # float(5,2)
    my $session_id = $c->sessionid;
    my $user_id = ($c->user_exists) ? $c->user->user_id : 0;
    
    $c->model('DBIC::LogPath')->create( {
        session_id => $session_id,
        user_id => $user_id,
        path => $path,
        get  => $get,
        post => $post,
        loadtime => $loadtime,
    } );
}

sub log_action {
    my ($self, $c, $info) = @_;

    my $user_id = $c->user_exists ? $c->user->user_id : 0;
    
    $c->model('DBIC::LogAction')->create( {
        user_id => $user_id,
        action  => $info->{action} || 'kiss',
        object_type => $info->{object_type} || 'ass',
        object_id   => $info->{object_id}   || 0, # times
        time    => \'NOW()',
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
