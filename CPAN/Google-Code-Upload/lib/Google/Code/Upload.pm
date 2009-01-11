package Google::Code::Upload;

use warnings;
use strict;
use File::Spec ();

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
