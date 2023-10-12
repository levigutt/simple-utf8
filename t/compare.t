#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use IPC::Run3;
use feature qw<say>;

my $testfile = 't/resources/unicode-string';
open my $stdin, '<', $testfile or die "couldn't open filehandle to $testfile";

open my $fh, '<', 't/resources/powerset' or die "could not read powerset: $!";
while(defined(my $combo = <$fh>))
{
    chomp($combo);
    my @expect_cmd = ('perl',              "-C$combo", 't/resources/script.pl', 'æøå');
    my @actual_cmd = ('perl', "-Mlib=.", "-MC=$combo", 't/resources/script.pl', 'æøå');

    my ($in, $out, $err) = ('')x3;
    seek($stdin, 0, 0);
    run3 \@expect_cmd, $stdin, \$out, \$err;
    chomp($err);
    my $expect_out = join'',split/\n/,$out // '';
    my $expect_err = join'',split/\n/,$err // '';

    ($in, $out, $err) = ('')x3;
    seek($stdin, 0, 0);
    run3 \@actual_cmd, $stdin, \$out, \$err;
    chomp($err);
    my $actual_out = join'',split/\n/,$out // '';
    my $actual_err = join'',split/\n/,$err // '';

    is($actual_out, $expect_out, "-MC=$combo has same stdout as -C$combo");
    is($actual_err, $expect_err, "-MC=$combo has same stderr as -C$combo");
}

done_testing;
