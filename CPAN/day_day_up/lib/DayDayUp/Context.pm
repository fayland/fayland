package DayDayUp::Context;

use Moose;

our $VERSION = '0.01';

extends 'Mojolicious::Context';

use YAML qw/LoadFile/;
use DBI;

has 'config' => (
    is   => 'ro',
    isa  => 'HashRef',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $home = $self->app->home;
        my $app  = $home->app_class;
        my $file = $home->rel_file( lc($app) . '.yml' );
        unless ( -e $file ) {
            warn "Can't find config with $file\n";
            return {};
        }
        my $config = YAML::LoadFile($file);
        
        # load _local.yml
        my $file_local = $home->rel_file( lc($app) . '_local.yml' );
        if ( -e $file_local ) {
        	my $local = YAML::LoadFile($file_local);
        	$config = { %$config, %$local };
        }
        
        return $config;
    }
);

has 'dbh' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $home = $self->app->home;
        my $app  = $home->app_class;
        my $db_file = $home->rel_file( lc($app) . '.db' );
        
        # custom
        if ( exists $self->config->{db_file} ) {
        	my $db_file2 = $home->rel_file( $self->config->{db_file} );
        	if ( -e $db_file2 ) {
        		$db_file = $db_file2;
        	} else {
        		warn "$db_file2 is not found\n";
        	}
        }
        
        return DBI->connect("dbi:SQLite:dbname=$db_file", '', '', {RaiseError => 1})
            or die $DBI::err;
    }
);

1;
