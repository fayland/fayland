package MooseX::TheSchwartz::Job;

use Moose;
use Moose::Util::TypeConstraints;
use Storable ();

subtype 'Args'
    => as 'Any'
    => where { 1; };
coerce 'Args'
    => from 'Str'
    => via { _cond_thaw($_) }
    => from 'ScalarRef'
    => via { Storable::thaw($$_) };

has 'jobid'         => ( is => 'rw', isa => 'Int' );
has 'funcid'        => ( is => 'rw', isa => 'Int' );
has 'arg'           => ( is => 'rw', isa => 'Args' );
has 'uniqkey'       => ( is => 'rw', isa => 'Maybe[Str]' );
has 'insert_time'   => ( is => 'rw', isa => 'Maybe[Int]' );
has 'run_after'     => ( is => 'rw', isa => 'Int', default => time() );
has 'grabbed_until' => ( is => 'rw', isa => 'Int', default => 0 );
has 'priority'      => ( is => 'rw', isa => 'Maybe[Int]' );
has 'coalesce'      => ( is => 'rw', isa => 'Maybe[Str]' );

has 'funcname'      => ( is => 'rw', isa => 'Str' );

sub as_hashref {
    my $self = shift;

    my %data;
    for my $col (qw( jobid funcid arg uniqkey insert_time run_after grabbed_until priority coalesce )) {
        $data{$col} = $self->$col if $self->can($col);
    }

    \%data;
}

sub completed {
    my $self = shift;
    
    
}

sub _cond_thaw {
    my $data = shift;

    my $magic = eval { Storable::read_magic($data); };
    if ($magic && $magic->{major} && $magic->{major} >= 2 && $magic->{major} <= 5) {
        my $thawed = eval { Storable::thaw($data) };
        if ($@) {
            # false alarm... looked like a Storable, but wasn't.
            return $data;
        }
        return $thawed;
    } else {
        return $data;
    }
}

1;
__END__
