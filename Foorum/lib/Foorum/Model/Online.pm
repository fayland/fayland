package Foorum::Model::Online;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub get_data {
    my ($self, $c, $forum_id) = @_;
    
    my @extra_cols; 
    if ($forum_id) {
        @extra_cols = ( -or => [
            'path' => { 'like', "forum/$forum_id/%" },
            'path' => { 'like', "forum/$forum_id" },
        ] );
    }
    # get the last 15 minites' data
    # 15 * 60 = 900
    my $last_15_min = time() - 900;
    my $rs = $c->model('DBIC::Session')->search( {
        expires =>  { '>', $last_15_min }, 
        @extra_cols,
    }, {
        order_by => 'expires',
    } ); 
    my @session = $rs->all;
     
    return wantarray?(\@session, $rs->pager):\@session;
}

1;
