package Catalyst::Plugin::tv_interval;

use warnings;
use strict;
use Time::HiRes qw( gettimeofday tv_interval );
use vars qw/$VERSION/;
$VERSION = '0.4';

sub tv_mark_point {
    my ($c, $timername) = @_;

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

sub tv_clear_marked_point {
    my ($c) = @_;
    
    eval {
        delete $c->stash->{__tv_interval};
    };
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
        # CODE { do something }
        $c->tv_mark_point; # print debug log how long this CODE takes
        
        $c->tv_clear_marked_point; # now it looks like we never call ->tv_mark_point before
        $c->tv_mark_point;
        # CODE { do something else }
        $c->tv_mark_point;
    }

=head1 DESCRIPTION

This module uses the functions of tv_interval and [gettimeofday] in L<Time::HiRes>. and print debug log like as follows:

    [debug] tv_interval: MyApp::Controller::Test from line 12 to 16 takes 0.013818
    [debug] tv_interval: MyApp::Controller::Test from line 16 to 22 takes 1.000408

=head1 INTERFACE

=head2 tv_mark_point

if this is no 'ponit' before, mark a point and remember the file name, line and the [gettimeofday]. or else, compare the 'point' now with the old 'point' and print debug log.

=head2 tv_clear_marked_point

clear the old 'point'

=head1 DEPENDENCIES & SEE ALSO

=over 4

=item L<Catalyst> - The Elegant MVC Web Application Framework

=item L<Time::HiRes> - High resolution alarm, sleep, gettimeofday, interval timers

=item Catalyst::Plugin::Timer (in Catalyst trunk) - something the same, but it is NOT working when I develop this module.

=back

=head1 AUTHOR

Fayland, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland and Zorpia Ltd. Company L<http://www.zorpia.com> all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
