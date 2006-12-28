package Foorum::Model::Visit;

use strict;
use warnings;
use base 'Catalyst::Model';
use Data::Dumper;

sub make_visited {
    my ($self, $c, $object_type, $object_id) = @_;
    
    return unless ($c->user_exists);
    $c->model('DBIC::Visit')->update_or_create( {
        user_id => $c->user->user_id,
        object_type => $object_type,
        object_id   => $object_id,
        time => time(),
    } );
}

sub make_un_visited {
    my ($self, $c, $object_type, $object_id) = @_;
    
    $c->model('DBIC::Visit')->search( {
        user_id => { '!=', $c->user->user_id },
        object_type => $object_type,
        object_id   => $object_id,
    } )->delete;
}

sub is_visited {
    my ($self, $c, $object_type, $object_id) = @_;
    
    return {} unless ($c->user_exists);
    my $visit;
    my @visits = $c->model('DBIC::Visit')->search( {
        user_id => $c->user->user_id,
        object_type => $object_type,
        object_id   => $object_id,
    }, {
        columns => ['object_id'],
    } )->all;
    foreach (@visits) {
        $visit->{$object_type}->{$_->object_id} = 1;
    }
    
    return $visit;
}

# we need remove some records in table 'visit' to avoid the expanding of this table
sub remove_records_for_cron {
    my ($self, $c, $how_long_ago) = @_;
    
    $c->model('DBIC::Visit')->search( {
        time => { '<', time() - $how_long_ago }
    } )->delete;
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
