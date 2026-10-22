## SYNOPSIS

```perl
use C 'SDA';
# process UTF-8 data
```

## DESCRIPTION

This module basically does what the `-C` flag does.

Except it uses `:encoding(UTF-8)` instead of the permissive `:utf8`.

## THE PROBLEM

By default, perl does not handle UTF-8 correctly:

```sh
$ perl -wle 'print length, $_ for "\x{1F600}$ARGV[0]"' Å
Wide character in print at -e line 1.
3😀Ã
```

A warning, wrong length for the string, and mojibake.

## THE SOLUTION

We can easily handle UTF-8 data with the `-C` flag:

```sh
$ perl -CSDA -wle 'print length, $_ for "\x{1F600}$ARGV[0]"' Å
2😀Å
```

That's nice for one-liners, but we can also add it to our shebang-line:

```perl
#!/usr/bin/env perl -CSDA
```

### THE PROBLEMS WITH -C

`-CSDA` is the equivalent of this:

```perl
#!/usr/bin/env perl
use open IO =>  ':utf8';
binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';
use Encode qw< _utf8_on >;
BEGIN { @ARGV = map { _utf8_on($_) } @ARGV }
...
```

Using `:utf8` is not recommended, as it simply marks the data as being UTF-8,
without validating if it actually is. It accepts malformed data, and
therefore cannot guarantee not to produce malformed data.

```sh
$ printf '\xC3\x28' | perl -C -ne 'print'
?(
```

Perl did not validate the data, and produced malformed output.

However, with warnings turned on, we would have been told:

```sh
$ printf '\xC3\x28' | perl -C -w -ne 'print'
utf8 "\xC3" does not map to Unicode, <> line 1.
?(
```

Since perl v5.10.1, when `-C` is used in the shebang-line, it must also be
supplied on the command line, or you will get this annoying error: `Too late
for "-C" option`.

Read more about [-C in perldoc](https://perldoc.pl/perlrun#-C-%5Bnumber/list%5D)
and note the caution at the top.

## THE ALTERNATIVE TO -C

This is the safe recommended equivalent of `-CSDA`:

```perl
#!/usr/bin/env perl
use open IO =>  ':encoding(UTF-8)';
binmode STDIN,  ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Encode qw< decode >;
BEGIN { @ARGV = map { decode('UTF-8', $_, Encode::FB_CROAK) } @ARGV }
...
```

### THE PROBLEM WITH THE ALTERNATIVE

`-C` is very neat for one-liner, but this is not.

Although we can be shortened it with `use open ':std'`, it still wont be
practical to write on the command line:

```sh
perl -Mopen=:std,IO,:encoding\(UTF-8\) -MEncode=decode,FB_CROAK -e 'BEGIN { @ARGV = map decode("UTF-8", $_, FB_CROAK),@ARGV } ...'
```

## THE NEW SOLUTION (THIS MODULE)

This modules simulates the behaviour of the `-C`  flag, letting you do this
instead:

```perl
#!/usr/bin/env perl
use C 'SDA';
...
```

And it's very suitable for one-liners, with familiar syntax:

```sh
perl -MC=SDA -e '...'
```

It uses `:encoding(UTF-8)`, so the data is validated.


```sh
$ printf '\xC3\x28' | perl -MC -wne 'print'
UTF-8 "\xC3" does not map to Unicode.
\xC3(
```

Output is not malformed.


## COMPATIBILITY WITH -C

The test suite should ensure that all possible options to `-C` and `-MC=`
produce identical output (on valid data), and the same warnings on invalid
data.

The effects of `-C128` are undocumented, but it basically does the same as
`-CA` except that it actually validates if the arguments are valid UTF-8. I
made sure to include this.

### INCOMPATIBILITIES

The `-C` flag sets `${^UNICODE}` and `${^OPEN}` but these are readonly, so we
can't assign to them.

Well, technically we can assign to `${^OPEN}` during compilation, which is
generally done with `use open IO => ...`, but then it gets reset and remains
undefined and readonly during runtime.

However, when `${^OPEN}` is set via `-C`, it remains defined during runtime.

To ensure these values can be inspected at runtime, this module sets
`$C::UNICODE` and `$C::OPEN` instead.

`-C` sets `${^OPEN}` to `:utf8\0:utf8`, but we must naturally set `$C::OPEN` to
`:encoding(UTF-8)\0:encoding(UTF-8)` to reflect the actual encoding used.

