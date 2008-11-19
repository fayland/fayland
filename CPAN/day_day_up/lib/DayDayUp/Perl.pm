package DayDayUp::Perl;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self, $c) = @_;
    
    $c->render(template => 'perl/index.html');
}

sub find_pod {
	my ($self, $c) = @_;
	
	my $params = $c->req->params->to_hash;
	my $module = $params->{module};
	
	# find the HTML place of a module
	my $stash = { template => 'perl/index.html', from => 'find_pod' };
	my $pod = `perldoc $module`;
	$stash->{content} = $pod;
	
	$c->render( $stash );
}

sub view_source {
	my ($self, $c) = @_;
	
	my $params = $c->req->params->to_hash;
	my $module = $params->{module};
	
	# find the HTML place of a module
	my $stash = { template => 'perl/index.html', from => 'view_source' };
	my $file = `perldoc -l $module`;
	my $code = "Can't find perldoc -l $module";
	if ( $file ) {
		chomp( $file );
		open(my $fh, '<', $file);
		local $/;
		$code = <$fh>;
		close($fh);
	}
	$stash->{content} = $code;
	
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
