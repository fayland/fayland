package Catalyst::Action::PathLogger;

use strict;
use warnings;
use base 'Catalyst::Action';
use Time::HiRes qw( gettimeofday tv_interval );
use Data::Dumper;

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;
    
    #$c->log->debug("controller is " . Dumper($controller));
    $self->NEXT::execute( @_ );
    
    my $loadtime = tv_interval( $c->stash->{start_t0}, [gettimeofday] );
    $c->model('Log')->log_path($c, $loadtime);
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
