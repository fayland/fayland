package TheSchwartz::Moosified::Utils;

use base 'Exporter';
use Carp;
use vars qw/@EXPORT_OK/;

@EXPORT_OK = qw/insert_id sql_for_unixtime/;

sub insert_id {
    my ( $dbh, $sth, $table, $col ) = @_;

    my $driver = $dbh->{Driver}{Name};
    if ( $driver eq 'mysql' ) {
        return $dbh->{mysql_insertid};
    }
    elsif ( $driver eq 'Pg' ) {
        return $dbh->last_insert_id( undef, undef, undef, undef,
            { sequence => join( "_", $table, $col, 'seq' ) } );
    }
    elsif ( $driver eq 'SQLite' ) {
        return $dbh->func('last_insert_rowid');
    }
    else {
        croak "Don't know how to get last insert id for $driver";
    }
}

# SQL doesn't define a function to ask a machine of its time in
# unixtime form.  MySQL does
# but for sqlite and others, we assume "remote" time is same as local
# machine's time, which is especially true for sqlite.
sub sql_for_unixtime {
    my ($dbh) = @_;
    
    my $driver = $dbh->{Driver}{Name};
    if ( $driver eq 'mysql' ) {
        return "UNIX_TIMESTAMP()";
    }
    
    return time();
}

1;
__END__
