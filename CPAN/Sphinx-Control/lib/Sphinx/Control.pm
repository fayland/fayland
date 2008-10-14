package Sphinx::Control;

use Moose;
use MooseX::Types::Path::Class;
use Path::Class;
use Errno qw/ECHILD/;

our $VERSION   = '0.03';
our $AUTHORITY = 'cpan:FAYLAND';

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

has 'pid_file' => (
    is      => 'rw',
    isa     => 'Path::Class::File',
    coerce  => 1,
    lazy    => 1,
    builder => '_find_pid_file',
);

has 'server_pid' => (
    init_arg => undef,
    is       => 'rw',
    isa      => 'Int',
    lazy     => 1,
    builder  => '_find_server_pid',
);

has 'indexer_args' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

sub log { shift; warn @_, "\n" }

## ---------------------------------
## events

sub pre_startup   { inner() }
sub post_startup  { inner() }

sub pre_shutdown  { inner() }
sub post_shutdown { inner() }

## ---------------------------------

sub _find_server_pid {
    my $self = shift;
    my $pid  = $self->pid_file->slurp(chomp => 1);
    ($pid)
        || confess "No PID found in pid_file (" . $self->pid_file . ")";
    $pid;
}

sub _find_pid_file {
    my $self = shift;
    
    my $config_file = $self->config_file;
    
    (-f $config_file)
        || confess "Could not find pid_file because could not find config file ($config_file)";

    my @approaches = (
        sub { $config_file->slurp(chomp => 1) },
    );
    
    foreach my $approach (@approaches) {    
        my @config = $approach->();
        foreach my $line (@config) {
            if ($line =~ /pid_file\s*\=\s*(.*)\s*/) {
                return Path::Class::File->new($1);
            }
        }
    }
    
    confess "Could not locate the pid-file information, please supply it manually";
}

sub _find_binary_path {
    my $self = shift;

    my $searchd = do {
        my $bin = `which searchd`;
        chomp($bin);
        Path::Class::File->new($bin)
    };

    return $searchd if -x $searchd;

    for my $prefix (qw(/usr /usr/local /opt/local /sw)) {
        for my $bindir (qw(bin sbin)) {
            my $searchd = Path::Class::File->new($prefix, $bindir, 'searchd');
            return $searchd if -x $searchd;
        }
    }

    confess "can't find searchd anywhere tried => (" . ($searchd || 'nothing') . ")";
}

sub _construct_command_line {
    my $self = shift;
    my @opts = @_;
    my $conf = $self->config_file;
    
    (-f $conf)
        || confess "Could not locate configuration file ($conf)";
    
    ($self->binary_path, @opts, '--config', $conf->stringify);
}

## ---------------------------------

sub is_server_running {
    my $self = shift;
    # no pid file, no server running ...
    return 0 unless -s $self->pid_file;
    # has pid file, then check it ...
    kill(0, $self->server_pid) ? 1 : 0;
}

sub start {
    my $self = shift;

    $self->log("Starting searchd ...");
    $self->pre_startup;

    # NOTE:
    # do this after startup so that it
    # would be possible to write the 
    # config file in the pre_startup
    # hook if we wanted to.
    # - SL
    my @cli = $self->_construct_command_line;

    unless (system(@cli) == 0) {
        $self->log("Could not start searchd (@cli) exited with status $?");
        return;
    }

    $self->post_startup;
    
    # update server_pid
    $self->server_pid( $self->_find_server_pid );
    
    $self->log("searchd started.");    
}

sub stop {
    my $self    = shift;
    my $pid_file = $self->pid_file;

    if (-f $pid_file) {
        
        if (!$self->is_server_running) {
            $self->log("Found pid_file($pid_file), but process does not seem to be running.");
            return;
        }
        
        $self->log("Stoping searchd ...");
        $self->pre_shutdown;
        
        kill 2, $self->server_pid;
        
        $self->post_shutdown;
        $self->log("searchd stopped.");    
        
        return;
    }

    $self->log("... pid_file($pid_file) not found.");
}

sub restart {
    my $self = shift;
    
    $self->log("Restarting searchd ...");
    $self->stop;
    
    $self->start;
    $self->log("searchd restarted.");
}

sub reload {
    my $self = shift;
    
    $self->log("reloading searchd ...");
    
    if ( $self->is_server_running ) {
    	# send HUP
    	kill 1, $self->server_pid;
    }
    else {
	    $self->start;
    }
    $self->log("searchd reloaded.");
}

sub run_indexer {
    my $self = shift;
    my @extra_args = @_;

    my $searchd = $self->binary_path;
    my $indexer = $searchd;
    $indexer =~ s/searchd$/indexer/is;

    confess "Cannot execute Sphinx indexer binary $indexer" unless -x $indexer;

    $self->log("starting indexer ...");

    my $config = $self->config_file->stringify;
    my $cmd = "$indexer --config $config";
    $cmd .= ' ' . join(" ", @{$self->indexer_args}) if $self->indexer_args;
    $cmd .= ' ' . join(" ", @extra_args) if @extra_args;

    $self->log("run $cmd...");
    if (my $status = _system_with_status($cmd)) {
	    confess $status;
    }

    $self->log("indexer done...");
}

sub _system_with_status {
    my ($command) = @_;

    local $SIG{CHLD} = 'IGNORE';
    my $status = system($command);
    unless ($status == 0) {
        if ($? == -1) {
	        return '' if $! == ECHILD;
            return "$command failed to execute: $!";
        }
        if ($? & 127) {
            return sprintf("$command died with signal %d, %s coredump\n",
                           ($? & 127),  ($? & 128) ? 'with' : 'without');
        }
        return sprintf("$command exited with value %d\n", $? >> 8);
    }
    return '';
}

no Moose; 1;

1;
__END__

=head1 NAME

Sphinx::Control - Simple class to manage a Sphinx searchd

=head1 SYNOPSIS

    use Sphinx::Control;
    
    my ($command) = @ARGV;
    
    my $ctl = Sphinx::Control->new(
        config_file => [qw[ conf sphinx.conf ]],
        # PID file can also be discovered automatically 
        # from the conf, or if you prefer you can specify
        pid_file    => 'searchd.pid',    
    );
  
    $ctl->start if lc($command) eq 'start';
    $ctl->stop  if lc($command) eq 'stop';

=head1 DESCRIPTION

This is a fork of L<Lighttpd::Control> to work with Sphinx searchd, it maintains 100%
API compatibility. In fact most of this documentation was stolen too. This is
an early release with only the bare bones functionality needed, future
releases will surely include more functionality. Suggestions and crazy ideas
welcomed, especially in the form of patches with tests.

=head1 ATTRIBUTES

=over 4

=item I<config_file>

This is a L<Path::Class::File> instance for the configuration file.

=item I<binary_path>

This is a L<Path::Class::File> instance pointing to the searchd 
binary. This can be autodiscovered or you can specify it via the 
constructor.

=item I<pid_file>

This is a L<Path::Class::File> instance pointing to the searchd 
pid file. This can be autodiscovered from the config file or you 
can specify it via the constructor.

=item I<server_pid>

This is the PID of the live server.

=back

=head1 METHODS 

=over 4

=item B<start>

Starts the Sphinx searchd deamon that is currently being controlled by this 
instance. It will also run the pre_startup and post_startup hooks.

=item B<stop>

Stops the Sphinx searchd deamon that is currently being controlled by this 
instance. It will also run the pre_shutdown and post_shutdown hooks.

=item B<restart>

Stops and thens starts the searchd daemon.

=item B<reload>

Sends a HUP signal to the searchd daemon if it is running, to tell it to reload
its databases; otherwise starts searchd.

=item B<is_server_running>

Checks to see if the Sphinx searchd deamon that is currently being controlled 
by this instance is running or not (based on the state of the PID file).

=head2 indexer_args

    $ctl->indexer_args(\@args)
    $args = $ctl->indexer_args;

Set/get the extra command line arguments to pass to the indexer program when
started using run_indexer.  These should be in the form of an array, each entry
comprising one option or option argument.  Arguments should exclude '--config
CONFIG_FILE', which is included on the command line by default.

=head2 run_indexer(@args)

Runs the indexer program; dies on error.  Arguments passed to the indexer are
"--config CONFIG_FILE" followed by args set through indexer_args, followed by
any additional args given as parameters to run_indexer.

Copied from L<Sphinx::Manager>

=item B<log>

Simple logger that you can use, it just sends the output to STDERR via
the C<warn> function.

=back

=head1 SEE ALSO

L<Sphinx::Manager>, L<Lighttpd::Control>, L<Nginx::Control>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam

except for those parts that are 

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
