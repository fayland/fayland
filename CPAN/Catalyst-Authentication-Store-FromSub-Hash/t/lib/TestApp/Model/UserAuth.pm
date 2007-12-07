package TestApp::Model::UserAuth;

use base qw/Catalyst::Model/;
use strict;

sub auth {
    my ($self, $c, $user_info) = @_;
    
    my $where;
    if (exists $user_info->{user_id}) {
        $where = { user_id => $user_info->{user_id} };
    } elsif (exists $user_info->{username}) {
        $where = { username => $user_info->{username} };
    } else { return; }

    my $user = $c->model('TestApp')->resultset('User')->search( $where )->first;
    $user = $user->{_column_data}; # hash

    if ( exists $user_info->{status} and ref $user_info->{status} eq 'ARRAY') {
        unless (grep { $_ eq $user->{status} } @{$user_info->{status}}) {
            return;
        }
    }
    
    return $user;
}

1;
