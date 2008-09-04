package MooseX::TheSchwartz::Job;

use Moose;

has 'jobid'         => ( is => 'rw', isa => 'Int' );
has 'funcid'        => ( is => 'rw', isa => 'Int' );
has 'arg'           => ( is => 'rw', isa => 'Any' );
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

1;
__END__
