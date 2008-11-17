package DayDayUp::Context;

use Moose;

extends 'Mojolicious::Context';

use YAML qw/LoadFile/;
use DBI;

has 'config' => (
	is => 'ro',
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
		return YAML::LoadFile($file);
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
		return DBI->connect("dbi:SQLite:dbname=$db_file", '', '', {RaiseError => 1})
			or die $DBI::err;
	}
);

1;
