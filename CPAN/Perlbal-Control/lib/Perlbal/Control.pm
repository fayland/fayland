package Perlbal::Control;

use Moose;
use Proc::ProcessTable;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

with 'MooseX::Control';

has '+control_name' => ( default => 'perlbal' );

sub pre_startup   { inner() }
sub post_startup  { inner() }

sub pre_shutdown  { inner() }
sub post_shutdown { inner() }

sub get_server_pid {
    my $self = shift;
    
    my $control_name = $self->control_name;
    my $pid_file     = $self->pid_file;
    my $config_file  = $self->config_file->stringify;
    
    if ( $pid_file ) {
        my $pid  = $pid_file->slurp(chomp => 1);
        ($pid)
            || confess "No PID found in pid_file (" . $pid_file . ")";
        return $pid;
    } else {
        my $p = new Proc::ProcessTable( 'cache_ttys' => 1 );
        my $all = $p->table;
        foreach my $one (@$all) {
            if ($one->cmndline =~ /$control_name/ and $one->cmndline =~ /$config_file/) {
                return $one->pid;
            }
        }
    }
    return 0;
}

sub construct_command_line {
    my $self = shift;
    my @opts = @_;
    my $conf = $self->config_file;
    
    (-f $conf)
        || confess "Could not locate configuration file ($conf)";
    
    ($self->binary_path, '--daemon', '--config', $conf->stringify);
}

sub find_pid_file {
    my $self = shift;
    
    my $config_file = $self->config_file;
    
    (-f $config_file)
        || confess "Could not find pid_file because could not find config file ($config_file)";

    my @approaches = (
        sub { $config_file->slurp(chomp => 1) },
    );
    
    # it's optional
    foreach my $approach (@approaches) {    
        my @config = $approach->();
        foreach my $line (@config) {
            if ($line =~ /pid_file\s*\=\s*(.*)\s*/) {
                return Path::Class::File->new($1);
            }
        }
    }
    
    # if not find, just return nothing
    return;
};

no Moose;

1;
__END__

=head1 NAME

Perlbal::Control - The great new Perlbal::Control!


=head1 SYNOPSIS

    use Perlbal::Control;

    my ($command) = @ARGV;
    
    my $ctl = Perlbal::Control->new(
        config_file => [qw[ conf perlbal.conf ]],
        # PID file can also be discovered automatically 
        # from the conf, or if you prefer you can specify
        pid_file    => 'searchd.pid',    
    );
  
    $ctl->start if lc($command) eq 'start';
    $ctl->stop  if lc($command) eq 'stop';

=head1 DESCRIPTION

This is a fork of L<Lighttpd::Control> to work with Perlbal, it maintains 100%
API compatibility. In fact most of this documentation was stolen too. This is
an early release with only the bare bones functionality needed, future
releases will surely include more functionality. Suggestions and crazy ideas
welcomed, especially in the form of patches with tests.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

The L<Moose> Team.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
