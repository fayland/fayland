package Catalyst::Plugin::tv_interval;

use warnings;
use strict;
use Time::HiRes qw( gettimeofday tv_interval );
use vars qw/$VERSION/;
$VERSION='0.1';

sub tv_mark_point {
    my ($c) = @_;

    return unless ($c->debug);

    my @call_pack = caller();
    my $new_name = $call_pack[0];
    my $new_line = $call_pack[2];
    if ($c->stash->{__tv_interval}) {
        my $old_name = $c->stash->{__tv_interval}->{name};
        my $old_line = $c->stash->{__tv_interval}->{line};
        my $old_time = $c->stash->{__tv_interval}->{time};
        
        my $elapsed = tv_interval( $old_time, [gettimeofday] );
        
        if ($new_name eq $old_name) {
            $c->log->debug("tv_interval: $new_name from line $old_line to $new_line takes $elapsed");
        } else {
            $c->log->debug("tv_interval: from $old_name line $old_line to $new_name line $new_line takes $elapsed");
        }
    }
    
    $c->stash->{__tv_interval} = { name => $new_name, line => $new_line, time => [gettimeofday] };
}

1; # mummy happy

__END__

=head1 NAME

Catalyst::Plugin::tv_interval - call tv_interval of Time::HiRes to ease profiling.

=head1 SYNOPSIS

    use Catalyst qw/-Debug tv_interval/;

    # in controller later
    sub somesub : Local {
        my ($self, $c) = @_;
        
        $c->tv_mark_point;
        
        # do something
        
        $c->tv_mark_point;
    }

=head1 DESCRIPTION

This module uses the functions of tv_interval and [gettimeofday] in L<Time::HiRes>. and print debug logs like as follows:

    [debug] tv_interval: MyApp::Controller::Test from line 12 to 16 takes 0.013818
    [debug] tv_interval: MyApp::Controller::Test from line 16 to 22 takes 1.000408

=head1 AUTHOR

Fayland, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland and Zorpia Ltd. Company L<http://www.zorpia.com> all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
