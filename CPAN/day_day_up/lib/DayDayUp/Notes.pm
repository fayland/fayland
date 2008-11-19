package DayDayUp::Notes;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Data::Dumper;

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
    $c->render(template => 'notes/index.html', notes => $notes, levels => \%levels);
}

sub add {
    my ( $self, $c ) = @_;
    
    my $stash = {
        template => 'notes/add.html',
        levels   => \%levels,
    };
    unless ( $c->req->method eq 'POST' ) {
        return $c->render( $stash );
    }
    
    my $config = $c->config;
    my $dbh = $c->dbh;
    my $params = $c->req->params->to_hash;
    
    my $notes = $params->{notes};
    my $level = $params->{level};
    my $sql = q~INSERT INTO notes ( note, level, status, time ) VALUES ( ?, ?, ?, ? )~;
    my $sth = $dbh->prepare($sql);
    $sth->execute( $notes, $level, 2, time() );
    
    $notes = $self->_get_notes( $c );
    $c->render(template => 'notes/index.html', notes => $notes, levels => \%levels);
}

sub _get_notes {
    my ( $self, $c ) = @_;
    
    my $notes;
    
    my $dbh = $c->dbh;
    
    # open
    my $sql = q~SELECT * FROM notes WHERE status = 2~; 
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    $notes->{open} = $sth->fetchall_arrayref({});
    
    # suspended
    $sql = q~SELECT * FROM notes WHERE status = 1~; 
    $sth = $dbh->prepare($sql);
    $sth->execute;
    $notes->{suspended} = $sth->fetchall_arrayref({});
    
    # closed
    $sql = q~SELECT * FROM notes WHERE status = 0 ORDER BY time DESC LIMIT 10~; 
    $sth = $dbh->prepare($sql);
    $sth->execute;
    $notes->{closed} = $sth->fetchall_arrayref({});
    
    return $notes;
}

sub edit {
    my ( $self, $c ) = @_;
    
    my $captures = $c->match->captures;
    my $id = $captures->{id};
    
    my $dbh = $c->dbh;
    
    # get the note
    my $sql = q~SELECT * FROM notes WHERE note_id = ?~;
    my $sth = $dbh->prepare($sql);
    $sth->execute( $id );
    my $note = $sth->fetchrow_hashref;
    
    my $stash = {
        template => 'notes/add.html',
        levels   => \%levels,
    };
    unless ( $c->req->method eq 'POST' ) {
    	# pre-fulfill
    	$stash->{fif} = {
    		level => $note->{level},
    		notes => $note->{note},
    	};
        return $c->render( $stash );
    }
    
    my $params = $c->req->params->to_hash;
    
    my $notes = $params->{notes};
    my $level = $params->{level};
    $sql = q~UPDATE notes SET note = ?, level = ? WHERE note_id = ?~;
    $sth = $dbh->prepare($sql);
    $sth->execute( $notes, $level, $id );
    
    $notes = $self->_get_notes( $c );
    $c->render(template => 'notes/index.html', notes => $notes, levels => \%levels);
}

sub delete {
    my ( $self, $c ) = @_;
    
    my $captures = $c->match->captures;
    my $id = $captures->{id};
    
    my $dbh = $c->dbh;
    my $sql = q~DELETE FROM notes WHERE note_id = ?~;
    my $sth = $dbh->prepare($sql);
    $sth->execute( $id );
    
    my $notes = $self->_get_notes( $c );
    $c->render(template => 'notes/index.html', notes => $notes, levels => \%levels);
}

1;
