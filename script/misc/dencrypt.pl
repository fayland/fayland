#!/usr/bin/perl
use strict;
use Crypt::CBC;

unless (scalar @ARGV == 3) {
    die "Usage: $0 encrypt|decrypt|en|de \$mysecretkey \$file_to_dencrypt";
}

my $type = shift @ARGV;
my $key = shift @ARGV;
my $file = shift @ARGV;

die "The first ARGV should be one of de, en, encrypt, decrypt" if ($type !~ /^(en|de)(crypt)?$/);
die "the file $file is not existence" unless (-f $file);

my $DEBUG = 1;

print "type is $type, key is $key, file is $file\n" if $DEBUG;

my $cipher = Crypt::CBC->new(
    -key    => $key,
    -cipher => 'Blowfish'
);

local $/;
open(FH, $file) or die $!;
flock(FH, 2);
my $data = <FH>;
close(FH);

my ($save_data, $save_file);
if ($type =~ /^en(crypt)?$/) {
    $save_data = $cipher->encrypt($data);
    $save_file = $file . '.encrypt';
} else {
    $save_data = $cipher->decrypt($data);
    $save_file = $file . '.decrypt';
}

open(FH, '>', $save_file) or die $!;
print FH $save_data;
close(FH);

if (-e $save_file) {
    print "$type file $file to $save_file OK\n";
} else {
    print "failed without reason\n";
}

