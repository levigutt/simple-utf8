#!/usr/bin/env perl
use strict;
use warnings;
use feature qw<say>;
use List::PowerSet 'powerset_lazy';


my @options = [qw< I O E S i o D A L >];
my %hash;
for my $v (@options) {
    my $ps = powerset_lazy(@$v);
    while (my $set = $ps->()) {
        my $str = join '', @$set;
        next if $hash{$str}++;
        #print "$str\n";
    }
}



say for grep { length }
        map { $_->[1] }
        sort { $a->[0] <=> $b->[0] }
        map { [length, $_] }
        keys %hash;

