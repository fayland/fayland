package Google::Code::Upload;

use warnings;
use strict;
use File::Spec ();
use File::Basename ();
use List::MoreUtils qw/natatime/

our $VERSION = '0.01';

sub get_svn_config_dir {
	if ( $^O eq 'MSWin32' ) {
		require Win32;
		return File::Spec->catdir( Win32::GetFolderPath( CSIDL_APPDATA ), 'Subversion' );
	}
	require File::HomeDir;
	my $home = File::HomeDir->my_home;
	return File::Spec->catdir( $home, '.subversion' );
}

sub get_svn_auth {
	my ( $project_name, $config_dir ) = @_;
	
	my $realm = "<https://$project_name.googlecode.com:443> Google Code Subversion Repository";
	
}

sub upload {
	my ( $file, $project_name, $username, $password, $summary, $labels ) = @_;
	
	$labels ||= [];
	if ( $username =~ /^(.*?)\@gmail\.com$/ ) {
		$username = $1;
	}
	
	my @form_fields = (
		summary => $summary,
	);
	push @form_fields, ( label => $_ ) foreach (@$lebals);
	
	my ( $content_type, $body ) = encode_upload_request(\@form_fields, $file);
}

sub encode_upload_request {
	my ($form_fields, $file) = @_;
	
	my $BOUNDARY = '----------Googlecode_boundary_reindeer_flotilla';
	my $CRLF = "\r\n";

	my @body;
	
	my $it = natatime 2, @$form_fields;
	while (my ( $key, $val ) = $it->()) {
		push @body, (
			"--$BOUNDARY",
			qq~Content-Disposition: form-data; name="$key"~,
			'',
			$value
		);
	}
	
	my $filename = File::Basename::basename($file);
	local $/;
	open(my $fh, '<', $file) or die $!;
	my $content = <$fh>;
	close($fh);
	
	push @body, (
		"--$BOUNDARY",
		qq~Content-Disposition: form-data; name="filename"; filename="$filename"'~,
		# The upload server determines the mime-type, no need to set it.
		'Content-Type: application/octet-stream',
		'',
		$content,
    );

	# Finalize the form body
	push @body, ("--$BOUNDARY--", '');

	return ("multipart/form-data; boundary=$BOUNDARY", join( $CRLF, @body ) );

}

1;
__END__

=head1 NAME

Google::Code::Upload - uploading files to a Google Code project.

=head1 SYNOPSIS

    use Google::Code::Upload;

    my $foo = Google::Code::Upload->new();
    ...

=head1 DESCRIPTION

It's a Perl port of L<http://support.googlecode.com/svn/trunk/scripts/googlecode_upload.py>

=haed1 METHODS

=head2 get_svn_config_dir

get svn config dir. "$home/Application Data/Subversion" for Win32, while ~/.subversion for others.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
