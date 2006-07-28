package Eplanet::C::BackUp;


use Data::Dumper;
use base 'Catalyst::Controller';

sub from_html : Global {
	my ( $self, $c) = @_;

	my $filedir = $c->config->{build_root} . "/journal/";
	opendir(DIR, $filedir);
	$c->log->debug('opendir');
	my @files = readdir(DIR);
	closedir(DIR);
	
	foreach my $file (@files) {
		next unless ($file !~ /\.html$/i);
		open(FH, "$filedir/$file");
		local $/;
		my $content = <FH>;
		close(FH);
		
		my %hash;
		$file =~ s/\.html$//;
		$hash{cms_file} = $file;
		if ($content =~ /\<title\>(.*?)\<\/title\>/) {
			$hash{cms_title} = $1;
		}
		
		Eplanet::M::CDBI::Cms->create(\%hash);
	}
	
	$c->res->body('pl');
}
1;
