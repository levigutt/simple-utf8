#!/usr/bin/env perl
use strict;
no warnings qw<utf8>; # silence 'Wide character in print' warnings
while(<STDIN>)
{
    chomp;
    print $ARGV[0], length $ARGV[0];
    print $_, length;
    warn $_, length, "\n";
    open my $fh, '<', 't/resources/unicode-string';
    while(<$fh>)
    {
        chomp;
        print $_, length;
        warn $_, length, "\n";
    }
}
print defined $C::UNICODE ? $C::UNICODE : ${^UNICODE};
