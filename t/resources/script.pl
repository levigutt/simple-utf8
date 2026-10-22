#!/usr/bin/env perl
use strict;
use warnings;
while(<STDIN>)
{
    print $ARGV[0], length $ARGV[0];
    print $_, length;
    warn $_, length;
    open my $fh, '<', 't/resources/unicode-string' or die $$;
    while(<$fh>)
    {
        print $_, length;
        warn $_, length;
    }
}
print defined $C::UNICODE ? $C::UNICODE : ${^UNICODE};
