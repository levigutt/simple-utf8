#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use IPC::Run3;

my @command = ('perl', '-Ilib', '-MC=SDA', '-wln', '-e', '');

my ($stdout, $stderr);
open my $stdin, '<', 't/resources/malformed' or die $!;
run3 \@command, $stdin, \$stdout, \$stderr;

print "STDERR: $stderr";

ok($stderr =~ /\\xC3/, "STDERR contains accurate representation of malformed unicode");

done_testing;
