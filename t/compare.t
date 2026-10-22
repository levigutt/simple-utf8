#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use IPC::Run3;

my @all_options = do {
    open my $fh, '<', 't/resources/powerset' or die $!;
    <$fh>
};
chomp @all_options;

my %test =  (   file      => 't/resources/unicode-string'
            ,   script    => 't/resources/script.pl'
            ,   arguments => ['æøå']
            ,   options   => \@all_options
            );

for my $option ($test{options}->@*)
{
    my @expect_cmd = ('perl',          "-C$option",   $test{script}, $test{arguments});
    my @actual_cmd = ('perl', "-Ilib", "-MC=$option", $test{script}, $test{arguments});

    open my $stdin, '<', $test{file} or die $!;
    my ($expect_out, $expect_err);
    my $success = run3 \@expect_cmd, $stdin, \$expect_out, \$expect_err;

    seek($stdin, 0, 0);
    my ($actual_out, $actual_err) = ('')x3;
    run3 \@actual_cmd, $stdin, \$actual_out, \$actual_err;

    is($actual_out, $expect_out, "STDOUT for $option with file $test{file}");
    is($actual_err, $expect_err, "STDERR for $option with file $test{file}");

    # run3 does not preserve exit codes, so we test them with system
    if ( !$success ) {
        my $expect_exit = system @expect_cmd;
        my $actual_exit = system @actual_cmd;
        is ( $actual_exit, $expect_exit, "EXIT CODE for $option with file $test{file}");
    }
}


done_testing;
