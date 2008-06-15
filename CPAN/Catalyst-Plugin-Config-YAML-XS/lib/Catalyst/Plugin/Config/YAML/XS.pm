package Catalyst::Plugin::Config::YAML::XS;

use warnings;
use strict;

use UNIVERSAL 'isa';

use NEXT;
use YAML::XS 'LoadFile';
use Path::Class 'file';

our $VERSION = '0.01';

sub setup {
	my $c = shift;
	my @config_files;
	if ( defined $c->config->{'config_file'} && ref $c->config->{'config_file'} eq 'ARRAY' ) {
		@config_files = @{$c->config->{'config_file'}};
	} else {
		my $config_file = $c->config->{'config_file'} || 'config.yml';
		push @config_files, $config_file;
	}
	foreach my $config_file ( @config_files ) {
		$config_file = file($c->config->{'home'}, $config_file) unless file($config_file)->is_absolute;
		next unless -e $config_file;
		my $options = LoadFile($config_file);
		$c->config($options);
	}
	$c->NEXT::setup;
}

1;
__END__

=head1 NAME

Catalyst::Plugin::Config::YAML::XS - Configure your Catalyst application via an 
external YAML file

=head1 SYNOPSIS

    use Catalyst 'Config::YAML::XS';
    
    __PACKAGE__->config('config_file' => 'config.yml');

=head1 DESCRIPTION

SEE L<Catalyst::Plugin::Config::YAML> for more details. The only change is use L<YAML::XS> instead of L<YAML>

Many Thanks to Bernhard Bauer.

=head1 SEE ALSO

L<Catalyst>, L<YAML::XS>.

=head1 AUTHOR

Fayland Lam, E<lt>fayland@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Fayland Lam

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut