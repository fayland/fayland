package IRC::Bot::Log::Extended;

use Moose;
use Carp 'croak';

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

extends 'IRC::Bot::Log';

has 'split_channel' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'split_day'     => ( is => 'rw', isa => 'Bool', default => 1 );
has 'Path'          => ( is => 'rw', isa => 'Str' );

override 'chan_log' => sub {
    my ( $self, $message ) = @_;

    if ( $self->{'Path'} ne 'null' ) {
        
        my $split_channel = $self->split_channel;
        my $split_day     = $self->split_channel;

        my $name = 'channel';
        if ( $split_channel ) {
            # [#moose 21:40] 
            my ($channel) = ( $message =~ /^\[\#(\S+)\s+/is );
            $name = $channel;
        }
        if ( $split_day ) {
            # get today
            my @atime = localtime();
            my $today = sprintf("%04d%02d%02d", $atime[5] + 1900, $atime[4] + 1, $atime[3]);
            $name .= "_$today"; 
        }
        my $file = $self->{'Path'} . $name . '.log';
        
        # create if not exists
        $self->touch_file($file);
        
        open( my $fh, '>>', $file ) || croak "Cannot Open $file!";
        print $fh "$message\n";
        close($fh) || croak "Cannot Close $file!";
    } else {
        return 0;
    }
}

sub touch_file {
    my ($self, $file) = @_;
    
    return if ( -e $file );
    
    open( my $fh, '>', $file ) || croak "Cannot Open $file!";
    print $fh "...\n";
    close($fh) || croak "Cannot Close $file!";
}

no Moose;

1;
__END__

=head1 NAME

IRC::Bot::Log::Extended - extends IRC::Bot::Log for IRC::Bot

=head1 SYNOPSIS

    use IRC::Bot;
    use IRC::Bot::Log::Extended;
    
    # Initialize new object
    my $bot = IRC::Bot->new(
        LogPath  => '/home/fayland/irclog/',
        Debug    => 0,
        Nick     => 'Fayland_logger',
        Server   => 'irc.perl.org',
        # ...
    );
    
    # override the log
    $bot::log = IRC::Bot::Log::Extended->new(
        Path          => $bot->{'LogPath'},
        split_channel => 1,
        split_day     => 1,
    );
    
    # Daemonize process
    $bot->daemon();
    
    # Run the bot
    $bot->run();


=head1 SEE ALSO

L<IRC::Bot>, L<IRC::Bot::Log>, L<Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
