package DayDayUp::Perl;

use strict;
use warnings;

use base 'Mojolicious::Controller';

our $VERSION = '0.04';

use File::Slurp        ();
use Data::Dumper;

sub index {
    my ($self, $c) = @_;
    
    $c->render(template => 'perl/index.html');
}

sub find_pod {
	my ($self, $c) = @_;
	
	my $params = $c->req->params->to_hash;
	my $module = $params->{module};
	
	my $stash = { template => 'perl/index.html', from => 'find_pod' };
	if ( $module ) {
		# find the HTML place of a module
		my $pod = `perldoc $module`;
		$stash->{content} = $pod;
	}
	
	$c->render( $stash );
}

sub view_source {
	my ($self, $c) = @_;
	
	my $params = $c->req->params->to_hash;
	my $module = $params->{module};

	my $stash = { template => 'perl/index.html', from => 'view_source' };
	if ( $module ) {
		# find the HTML place of a module
		my $file = `perldoc -l $module`;
		#$c->app->log->debug("perldoc -l $module return $file");
		my $code = "Can't find $module";
		if ( $file ) {
			chomp( $file );
			$code = eval { File::Slurp::read_file($file, binmode => ':raw') };
			$code = "# $file\n$code";
			$code = $@ if $@;
		}
		$stash->{content} = $code;
	}
	
	$c->render( $stash );
}

1;
__END__

=head1 NAME

DayDayUp::Perl - Mojolicious::Controller, /perl/

=head1 URL

	/perl/
	/perl/find_pod
	/perl/view_source

=head1 AUTHOR

Fayland Lam < fayland at gmail dot com >

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
