#!perl

use Test::More;

use XML::HARef qw/ref_to_xml/;

BEGIN {
    eval { require File::Find::Rule }
        or plan skip_all =>
        "File::Find::Rule is required for this test";

};

use FindBin qw/$Bin/;
my @files = File::Find::Rule->file()->name('*.xml')->in( "$Bin/examples" );

plan tests => scalar @files;

foreach my $xml_file ( @files ) {
	my $txt_file = $xml_file;
	$txt_file =~ s/\.xml$/\.txt/;
	
	# get xml and txt
	open(my $fh, '<', $xml_file);
	local $/;
	my $xml = <$fh>;
	close($fh);
	$xml =~ s/^\s+//mg;
	$xml =~ s/\r?\n//g;
	
	open(my $fh2, '<', $txt_file);
	my $txt = <$fh2>;
	close($fh2);
	
	my $var;
	eval("\$var = $txt") or die $!;
	
	my $ret = ref_to_xml( $var );
	is $ret, $xml;
}

1;