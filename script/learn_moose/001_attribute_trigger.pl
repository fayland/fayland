#!/usr/bin/perl

package Test;

use Moose;
use File::Spec;

has 'scoreboard'  => (
    is => 'rw',
    isa => 'Str',
    trigger => sub {
        my ($self, $dir) = @_;
        
        return unless $dir;
        # no endless loop when it's a file
        if ($dir =~ /\/theschwartz\/scoreboard\./is) {
            # get the real dir from $dir regardless a file
            my (undef, $dir) = File::Spec->splitpath( $dir );
            unless (-e $dir) {
                mkdir($dir, 0755) or die "Can't create scoreboard directory '$dir': $!";
            }
            return;
        }

        # They want the scoreboard but don't care where it goes
        if (($dir eq '1') or ($dir eq 'on')) {
            $dir = File::Spec->tmpdir();
        }
    
        $dir .= '/theschwartz';
        unless (-e $dir) {
            mkdir($dir, 0755) or die "Can't create scoreboard directory '$dir': $!";
        }
        
        $self->{scoreboard} = $dir."/scoreboard.$$";
    }
);

package main;

no Moose;

my $t = new Test( scoreboard => 1 );
print $t->scoreboard . "\n";

my $t2 = new Test;
$t2->scoreboard('./theschwartz/scoreboard.1234');
print $t2->scoreboard . "\n";

1;