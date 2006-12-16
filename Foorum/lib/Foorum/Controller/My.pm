package Foorum::Controller::My;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Foorum::Utils qw/get_page_no_from_url/;

sub starred : Local {
    my ($self, $c) = @_;
    
    return $c->res->redirect('/login') unless ($c->user_exists);
    
    my $page = get_page_no_from_url($c->req->path);
    
    my $rs = $c->model('DBIC::Star')->search( {
        user_id => $c->user->user_id,
    }, {
        order_by => \'time DESC',
        rows => 20,
        page => $page,
    } );
    
    my @objects = $rs->all;
    
    my @starred_items;
    foreach my $rec (@objects) {
        my $object = $c->model('Object')->get_object_by_type_id($c, { object_type => $rec->object_type, object_id => $rec->object_id, } );
        next unless ($object);
        push @starred_items, { object_type => $rec->object_type, object_id => $rec->object_id, object => $object };
    }
        
    
    $c->stash( {
        template => 'my/starred.html',
        starred_items => \@starred_items,
        pager => $rs->pager,
        url_prefix => '/my/starred',
    } );
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
