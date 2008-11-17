package DayDayUp::Index;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Data::Dumper;

sub welcome {
    my ($self, $c) = @_;
    
    my $config = $c->config;
    my $dbh = $c->dbh;
    
    $c->render(template => $c->app->home->rel_file('index/welcome.html') );
}

1;
