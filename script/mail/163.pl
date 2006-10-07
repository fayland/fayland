#!/usr/bin/perl -w 

use strict;
use Net::SMTP;

my $smtp = Net::SMTP->new('smtp.163.com', Port => 25, Timeout => 60, Debug => 1);

$smtp->auth('username', 'password');
$smtp->mail('usernmae@163.com');
$smtp->to('to@gmail.com');
$smtp->data();
$smtp->datasend("To: username\@gmail.com\n");
$smtp->datasend("From: to\@163.com\n");
$smtp->datasend("Subject: A Simple Test Message\n");
$smtp->datasend("\n");
$smtp->datasend("A simple test message\n");
$smtp->dataend();

$smtp->quit;