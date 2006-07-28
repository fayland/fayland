package Eplanet::C::Setting;

use YAML;
use Carp;
use base 'Catalyst::Base';

sub settings : Global {
	my ( $self, $c, $action) = @_;
	
	my $file_config = $c->config->{root} . '/config.yml';
	
	if (defined $action) {
		YAML::DumpFile($file_config, $c->req->params);
		$c->res->output( 'YAML' );
	} else {
		$c->stash->{config} = YAML::LoadFile($file_config) if (-e $file_config);
	}

}

# etst

1;