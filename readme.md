## SYNOPSIS

by default, perl thinks `æøå` is 6 characters:

```sh
$ perl -e 'print $_, length for @ARGV' æøå
æøå6
```

easy fix using the -C flag:

```sh
$ perl -CSiA -e 'print $_, length for @ARGV' æøå
æøå3
```

which is roughly the equivalent of this:

```perl
#/usr/bin/env perl
use open IO =>  ':utf8';
binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';
use Encode qw<decode>;
@ARGV = map { decode 'utf8', $_ } @ARGV

print $_, length for @ARGV;
```

this modules simulates the behaviour of the -C  flag, letting you do this
instead:

```perl
#!/usr/bin/env perl
use C 'SiA';
print $_, length for @ARGV;
```

## WHY?

because life is too short.

## CAVEATS

the -C flag sets `${^UNICODE}`, but this variable cannot be assigned to, so
this moduls sets `$C::UNICODE` instead to the same value:

```perl
use C 'SD';
print $C::UNICODE; # 31
```

calling `use C` with a numberic value, will attempt to load a specific version
of the module, rather than setting the flag to the given value. you should
combine letters to get the desired value instead:

```perl
use C 3;     # bad
use C '3';   # also bad
use C qw<3>; # works..
use C 'IO';  # best
```

the `${^OPEN}` variable cannot be set at runtime, any code that depend on this
will therefore still use the default encoding for IO operations.

