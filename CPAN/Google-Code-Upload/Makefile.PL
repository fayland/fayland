use inc::Module::Install;

name     'Google-Code-Upload';
all_from 'lib/Google/Code/Upload.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

my $has_svn_core = 'use SVN::Core; 1;';
unless ( $has_svn_core ) {
	requires 'Alien::SVN';
}

if ( $^O eq 'MSWin32' ) {
	requires 'Win32';
} else {
	requires 'File::HomeDir';
}

build_requires 'Test::More';

auto_install;

WriteAll;

