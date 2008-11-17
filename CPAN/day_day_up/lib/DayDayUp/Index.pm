package DayDayUp::Index;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Data::Dumper;

sub welcome {
    my ($self, $c) = @_;
    
    my $config = $c->config;
    my $dbh = $c->dbh;
    
    $c->render(template => 'index/welcome.html' );
}

1;
