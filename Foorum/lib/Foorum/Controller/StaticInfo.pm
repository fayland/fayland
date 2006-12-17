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
    
    _static_info($c, 'help', $help_id);
}

sub info : Global {
    my ($self, $c, $info_id) = @_;
    
    _static_info($c, 'info', $info_id);
}

sub _static_info {
    my ($c, $type, $type_id) = @_;
    
    if ($type_id) {
        $type_id =~ s/\W+//isg;
        my $help_template = $c->path_to('templates', $c->stash->{lang}, $type, "$type_id.html")->stringify;
        if (-e $help_template) {
            $c->stash->{template} = "$type/$type_id.html";
        } else {
            $c->stash->{template} = "$type/index.html";
        }
    } else {
        $c->stash->{template} = "$type/index.html";
    }
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
