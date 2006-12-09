package Foorum::Controller::StaticInfo;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;

sub begin : Private {
    my ($self, $c) = @_;
    
    $c->stash( {
        no_online_view => 1,
    } );
}

sub help : Global {
    my ($self, $c, $help_id) = @_;
    
    if ($help_id) {
        $help_id =~ s/\W+//isg;
        my $help_template = $c->path_to('templates', $c->stash->{lang}, 'help', "$help_id.html");
        if (-e $help_template) {
            $c->stash->{template} = "help/$help_id.html";
        } else {
            $c->stash->{template} = "help/index.html";
        }
    } else {
        $c->stash->{template} = "help/index.html";
    }
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
