package Foorum::Controller::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

local $Data::Dumper::Freezer = '_dumper_hook';

use Time::HiRes qw( gettimeofday tv_interval );

sub test : Global {
    my ( $self, $c ) = @_;

    my $faked_rs = $c->model('DBIC::User')->single( { user_id => 2 } );
    $c->res->body(Dumper($faked_rs));
}

sub _dumper_hook {
    $_[0] = bless {
      %{ $_[0] },
      result_source => undef,
    }, ref($_[0]);
}


=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;