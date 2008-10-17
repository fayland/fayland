package MooseX::Control;

use Moose::Role;
use Moose::Util::TypeConstraints;
use MooseX::Types::Path::Class;
use Path::Class;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

has 'control_name' => (
    is   => 'rw',
    isa  => 'Str',
    default => 'unkown',
);

has 'config_file' => (
    is       => 'rw',
    isa      => 'Path::Class::File',
    coerce   => 1,
);

has 'binary_path' => (
    is      => 'rw',
    isa     => 'Path::Class::File',
    coerce  => 1,
    lazy    => 1,
    builder => '_find_binary_path'
);

sub _find_binary_path {
    my $self = shift;

    my $control_name = $self->control_name;
    my $control_exe = do {
        my $bin = `which $control_name`;
        chomp($bin);
        Path::Class::File->new($bin)
    };

    return $control_exe if -x $control_exe;

    for my $prefix (qw(/usr /usr/local /opt/local /sw)) {
        for my $bindir (qw(bin sbin)) {
            my $control_exe = Path::Class::File->new($prefix, $bindir, $control_name);
            return $control_exe if -x $control_exe;
        }
    }

    confess "can't find $control_name anywhere tried => (" . ($control_exe || 'nothing') . ")";
}

has 'pid_file' => (
    is      => 'rw',
    isa     => 'Path::Class::File',
    coerce  => 1,
    lazy    => 1,
    builder => 'find_pid_file',
);

my $sub_verbose = sub {
    my $msg = shift;
    $msg =~ s/\s+$//;
    print STDERR "$msg\n";
};
subtype 'Verbose'
    => as 'CodeRef'
    => where { 1; };
coerce 'Verbose'
    => from 'Int'
    => via {
        if ($_) {
            return $sub_verbose;
        } else {
            return sub { 0 };
        }
    };

has 'verbose' => ( is => 'rw', isa => 'Verbose', coerce => 1, default => 0 );

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
}

sub pre_startup   { inner() }
sub post_startup  { inner() }

sub pre_shutdown  { inner() }
sub post_shutdown { inner() }

requires 'find_pid_file';
requires 'get_server_pid';
requires 'construct_command_line';

sub is_server_running {
    my $self = shift;
    
    my $pid_file = $self->pid_file;
    
    # no pid file, no server running ...
    if ($pid_file and not -s $self->pid_file) {
        return 0;
    }

    # check it ...
    kill(0, $self->get_server_pid) ? 1 : 0;
}

sub start {
    my $self = shift;
    
    my $control_name = $self->control_name;

    $self->debug("Starting $control_name ...");
    $self->pre_startup;

    # NOTE:
    # do this after startup so that it
    # would be possible to write the 
    # config file in the pre_startup
    # hook if we wanted to.
    # - SL
    my @cli = $self->construct_command_line;

    unless (system(@cli) == 0) {
        $self->debug("Could not start $control_name (@cli) exited with status $?");
        return;
    }

    $self->post_startup;

    $self->debug("$control_name started.");    
}

sub stop {
    my $self    = shift;
    
    my $control_name = $self->control_name;
    
    if ( $self->is_server_running ) {

        $self->debug("Stoping $control_name ...");
        $self->pre_shutdown;
        
        kill 2, $self->get_server_pid;
        
        $self->post_shutdown;
        $self->debug("$control_name stopped.");    
        
        return;
    }

    $self->debug("server is not running.");
}

no Moose;
no Moose::Util::TypeConstraints;

1;
__END__

=head1 NAME

MooseX::Control - Simple class to manage a execute deamon

=head1 SYNOPSIS

    package XXXX::Control;
    
    use Moose;
    with 'MooseX::Control';
    
    

=head1 DESCRIPTION

It is a Moose Role to ease writing XXX::Control like L<Sphinx::Control>, L<Perlbal::Control>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Thanks to the L<Moose> Team.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
