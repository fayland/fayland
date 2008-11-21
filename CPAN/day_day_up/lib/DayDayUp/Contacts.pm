package DayDayUp::Contacts;

use strict;
use warnings;

use base 'Mojolicious::Controller';

our $VERSION = '0.04';

use Data::Dumper;
use WWW::Contact;

sub index {
    my ($self, $c) = @_;
    
    my $contacts = $self->_get( $c );
    $c->render(template => 'contacts/index.html', contacts => $contacts );
}

sub _get {
	my ( $self, $c ) = @_;
	
	my $dbh = $c->dbh;
    my $sql = q~SELECT * FROM contacts~; 
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    return $sth->fetchall_arrayref({});
}

sub import {
	my ( $self, $c ) = @_;
	
	my $params = $c->req->params->to_hash;
	
	my $email = $params->{email};
	my $pass  = $params->{pass};
	
	my $stash = { template => 'contacts/index.html' };
	unless ( $email and $pass ) {
		return $c->render( $stash );
	}
	
	my $wc = WWW::Contact->new();
	my @contacts = $wc->get_contacts($email, $pass);
    my $errstr   = $wc->errstr;
	if ( $errstr ) {
		$stash->{err} = $errstr;
	} elsif (scalar @contacts) {
		# insert into database
		my $dbh = $c->dbh;
		my $sql_c = q~SELECT COUNT(*) FROM contacts WHERE email = ?~;
		my $sth_c = $dbh->prepare( $sql_c );
		my $sql_i = q~INSERT INTO contacts ( email, name ) VALUES ( ?, ? )~;
		my $sth_i = $dbh->prepare( $sql_i );
		foreach my $contact ( @contacts ) {
			my $name  = $contact->{name};
			my $email = $contact->{email};
			$sth_c->execute( $email );
			my ( $row ) = $sth_c->fetchrow_array;
			unless ( $row ) {
				$sth_i->execute( $email, $name );
			}
		}
		$stash = { template => 'redirect.html', url => '/contacts/' };
	}
	$c->render( $stash );
}

1;
__END__

=head1 NAME

DayDayUp::Contacts - Mojolicious::Controller, /contact/

=head1 URL

	/contacts/
	/contacts/import

=head1 TABLE

	CREATE TABLE "contacts" (
		"contact_id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL ,
		"name" VARCHAR, "email" VARCHAR,
		"phone" VARCHAR, "group" VARCHAR,
		"notes" TEXT)

=head1 AUTHOR

Fayland Lam < fayland at gmail dot com >

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
