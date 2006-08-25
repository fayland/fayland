package Foorum::Controller::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

sub test : Global {
    my ( $self, $c ) = @_;

    my $output;
    my $t1 = [gettimeofday];
    my $rs1 = $c->model('DBIC::Comment')->search( { author_id => 1 } )->first;
    my $t2 = [gettimeofday];
    my $rs2 = $c->model('DBIC::Comment')->single( { author_id => 1 } );
    my $t3 = [gettimeofday];
    my $rs3 = $c->model('DBIC::Comment')->find( { author_id => 1 } );
    my $t4 = [gettimeofday];
    use Data::Compare;
    $output .= "Rs1 and rs2 ";
    $output .= Compare($rs1, $rs2) ? "identical" : "not identical";
    $output .= "\nRs2 and rs3 ";
    $output .= Compare($rs2, $rs3) ? "identical" : "not identical";
    $output .= "\nRs1 takes " . tv_interval( $t1, $t2 ) . "\nRs2 takes " . tv_interval( $t2, $t3 ) . "\nRs3 takes " . tv_interval( $t3, $t4 );
    $c->res->body($output);
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;