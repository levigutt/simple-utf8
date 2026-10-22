#!/usr/bin/env perl -wl
use strict;
use List::PowerSet 'powerset_lazy';

my @options = qw< I O E S i o D A L a >;
my $ps = powerset_lazy(@options);
my %seen;
while (my $set = $ps->()) {
    my $str = join '', @$set;
    $seen{$str}++;
}

print for 0 .. 512;
print "X";

print for map  { $_->[1]                }
          sort { $a->[0] <=> $b->[0]
              || $a->[1] cmp $b->[1]    }
          map  { [length, $_]           }
          grep { length                 }
          keys %seen;
