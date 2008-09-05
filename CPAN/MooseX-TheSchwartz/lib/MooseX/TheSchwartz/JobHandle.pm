package MooseX::TheSchwartz::JobHandle;

use TheSchwartz::Job;
use Moose;

has 'jobid'  => ( is => 'rw', isa => 'Int' );
has 'client' => ( is => 'rw', isa => 'Object' );
has 'dbh'    => ( is => 'rw', isa => 'Object' );

1;
__END__
