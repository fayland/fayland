#!/usr/bin/perl

use strict;
use warnings;
use LWP;
use vars '@ISA'; # for get_basic_credentials
@ISA = 'LWP::UserAgent';
use Getopt::Long;
my $username;
my $password;
my $hostname;

GetOptions("username=s" => \$username,
           "password=s" => \$password,
           "hostname=s" => \$hostname);

unless ($username and $password and $hostname) {
    die <<USAGE;
perl $0 --hostname fayland.3322.org --username fayland --password xxxx
USAGE
}

my $url = "http://www.3322.org/dyndns/update?system=dyndns&hostname=$hostname";

my $agent = __PACKAGE__->new;
my $request = HTTP::Request->new(GET => $url);

my $response = $agent->request($request);
$response->is_success or die $response->message;

print $response->content;

sub get_basic_credentials {
	return ($username, $password);
}