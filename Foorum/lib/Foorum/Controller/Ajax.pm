package Foorum::Controller::Ajax;

use strict;
use warnings;
use base 'Catalyst::Controller';
use YAML::Syck;
use Data::Dumper;

=pod

=item new_message

(Global Site) check if a user get any message

=cut

sub new_message : Local {
    my ($self, $c) = @_;
    
    return unless ($c->user_exists);
    
    my $count = $c->model('DBIC::MessageUnread')->count( {
        user_id => $c->user->user_id,
    } );
    
    if ($count) {
        $c->res->body("<span style='color:red'>You have new messages ($count)</span>");
    }
    
}

=pod

=item loadstyle?style=$stylename

(ForumAdmin.pm/style) Load the $stylename.yml under HOME/style, and print the javscript

=cut

sub loadstyle : Local {
    my ($self, $c) = @_;
    
    my $style = $c->req->param('style');
    return unless ($style);
    $style =~ s/\W+/\_/isg;
    
    my $output;
    
    return unless (-e $c->path_to('style', 'system', "$style\.yml"));
    
    $style = LoadFile($c->path_to('style', 'system', "$style\.yml"));
    
    foreach (keys %{$style}) {
        my $background = qq~\$('$_').style.background = "$style->{$_}";~ if ($style->{$_} =~ /^\#/);
        $output .= <<JAVASCRIPT;
        \$('$_').value = "$style->{$_}";
        $background
JAVASCRIPT
    }
    
    $c->res->content_type('text/javascript');
    $c->res->body($output);
}

sub auto : Private {
    my ($self, $c) = @_;
    
    # no cache
    $c->res->header( 'Cache-Control' => 'no-cache, must-revalidate, max-age=0' );
    $c->res->header( 'Pragma' => 'no-cache' );
    
    return 1;
}

# override Root.pm
sub end : Private {
    my ($self, $c) = @_;
    

}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
