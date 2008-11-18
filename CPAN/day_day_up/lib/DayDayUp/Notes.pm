package DayDayUp::Notes;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub index {
    my ($self, $c) = @_;
    
    my $config = $c->config;
    my $dbh = $c->dbh;
    
    $c->render(template => 'notes/index.html' );
}

1;
