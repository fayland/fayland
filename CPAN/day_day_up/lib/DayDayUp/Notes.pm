package DayDayUp::Notes;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use vars qw/%levels %status/;
%levels = (
	99 => 'A-1',
	98 => 'A-2',
	97 => 'A-3',
	66 => 'B-1',
	65 => 'B-2',
	64 => 'B-3',
	33 => 'C-1',
	32 => 'C-2',
	31 => 'C-3',
);
%status = (
	0  => 'closed',
	1  => 'suspended',
	2  => 'open',
);

sub index {
    my ($self, $c) = @_;
    
    my $config = $c->config;
    my $dbh = $c->dbh;
    
    my $notes = $self->_get_notes( $c );
    $c->render(template => 'notes/index.html', notes => $notes);
}

sub add {
	my ( $self, $c ) = @_;
	
	my $stash;
	$stash->{template} = 'notes/add.html';
	unless ( $c->req->method eq 'POST' ) {
		return $c->render( $stash );
	}
	
	my $config = $c->config;
    my $dbh = $c->dbh;
    my $params = $c->req->params->to_hash;
    
    my $notes = $params->{notes};
    my $level = 65; # hardcoded now
    my $sql = q~INSERT INTO notes ( note, level, status ) VALUES ( ?, ?, ? )~;
    my $sth = $dbh->prepare($sql);
    $sth->execute( $notes, $level, 2);
    
    $notes = $self->_get_notes( $c );
    $c->render(template => 'notes/index.html', notes => $notes);
}

sub _get_notes {
	my ( $self, $c ) = @_;
	
	my $dbh = $c->dbh;
	my $sql = q~SELECT * FROM notes WHERE status = 2~; # open
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	
	
	
	return $sth->fetchall_arrayref({});
}

1;
