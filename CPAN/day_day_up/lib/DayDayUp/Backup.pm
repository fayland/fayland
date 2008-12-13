package DayDayUp::Backup;

use strict;
use warnings;

our $VERSION = '0.07';

use base 'Mojolicious::Controller';

use Scope::Guard;

sub index {
    my ($self, $c) = @_;

	my $config = $c->config;
	# for FillInForm
	my $fif = $config->{backup};

    $c->render( template => 'backup/index.html', fif => $fif );
}

sub ftp {
	my ($self, $c) = @_;
	
	my $config = $c->config;
	my $dbh = $c->dbh;
    my $params = $c->req->params->to_hash;
    
    my $host = $params->{host};
    my $user = $params->{user};
    my $pass = $params->{pass};
    my $mode = $params->{mode};
    my $local  = $params->{local};
    my $remote = $params->{remote};
    my $get_file = $params->{get_file};
    my $put_file = $params->{put_file};
    
    my $err;
    
    my $sg = Scope::Guard->new(
		sub { $c->render( template => 'backup/index.html', err => $err ) }
	);

    if ( $put_file and not -e $local ) {
    	return $err = "Local $local is not there";
    }

    #### start use Net::SFTP
    eval {
		require Net::FTP;
	};
	return $err = $@ if ( $@ );
    
    my $ftp = Net::FTP->new($host, Debug => 0)
      or do { return $err = "Cannot connect to $host: $@"; };
    
    $ftp->login($user, $pass)
      or do { return $err = "Cannot login " . $ftp->message; };

	
	if ( $mode eq 'binary' ) {
		$ftp->binary;
	} elsif ( $mode eq 'ascii') {
		$ftp->ascii;
	} else {
		if ( -e $local and -T $local ) {
			$ftp->binary;
		} else {
			$ftp->ascii;
		}
	}

	if ( $get_file ) {
		$ftp->get($remote, $local)
			or do { return $err = "get failed " . $ftp->message; };
	}
	if ( $put_file ) {
		$ftp->put($local, $remote)
			or do { return $err = "put failed " . $ftp->message; };
	}
	
	if ( $params->{save} ) {
		$config->{backup} = {
			host => $host,
			user => $user,
			local => $local,
			remote => $remote,
		};
		$c->save_config( $config );
	}
	
	$ftp->quit;
	$err = "Everything seems OK";
}

1;
__END__

=head1 NAME

DayDayUp::Backup - Mojolicious::Controller, /backup

=head1 URL

	/backup
	/backup/ftp

=head1 AUTHOR

Fayland Lam < fayland at gmail dot com >

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut