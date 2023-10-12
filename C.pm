package C;
use strict;
use Encode qw<decode>;
use Filter::Simple;
use Carp;

our $UNICODE  = 95;
our $SET_UTF8 = 1;
our $ENCODING = 'UTF-8'; # better than utf8

# intended to simulate the same behaviour as the -C flag on the command line
# -C63 sets utf8 for STDIN, STDOUT, STDERR, default filehandles, and decodes @ARGV as utf8
# -MC=63 does the same
# after using -C, the flags can be read from ${^UNICODE}
# after using -MC, the flags can be read from $C::UNICODE
sub import
{   $UNICODE = process_args(@_);
    $SET_UTF8 = is_locale_utf8();

    if( $SET_UTF8 )
    {   $UNICODE & 1   and binmode STDIN,  ":encoding($ENCODING)";
        $UNICODE & 2   and binmode STDOUT, ":encoding($ENCODING)";
        $UNICODE & 4   and binmode STDERR, ":encoding($ENCODING)";
        $UNICODE & 32  and @ARGV = map { decode $ENCODING, $_; } @ARGV;
    }
    $UNICODE & 256 and ${^UTF8CACHE} = -1;
}

FILTER
{   if( $SET_UTF8 )
    {   s/^/use open IN  => ':encoding($ENCODING)';\n/ if $UNICODE & 8;
        s/^/use open OUT => ':encoding($ENCODING)';\n/ if $UNICODE & 16;
    }
};

sub process_args
{   local (undef, $_) = @_;
    my $flags;
    if( /^[0-9]+$/ )
    {   $flags = 0+$_;
    }
    else
    {   $flags = 0;
        my %letters = (     I => 1      # STDIN
                      ,     O => 2      # STDOUT
                      ,     E => 4      # STDERR
                      ,     S => 7      # I + O + E
                      ,     i => 8      # input stream default
                      ,     o => 16     # output stream default
                      ,     D => 24     # i + o
                      ,     A => 32     # @ARGV
                      ,     L => 64     # conditional IOEioA
                      ,     a => 256    # debug mode for UTF-8 caching
                      );
        for (split//)
        {   carp "Unknown Unicode option letter '$_'." and exit 1 unless exists $letters{$_};
            $flags |= $letters{$_};
        }
    }
    return $flags;
}

# conditional IOEioA - only set utf8 if system locale indicated utf8
sub is_locale_utf8
{   return 1 unless $UNICODE & 64;

    # also check LC_TYPE LANGUAGE?
    for (qw<LC_ALL LC_CTYPE LANG>)
    {   next  unless exists $ENV{$_};
        # checking for en_US.UTF-8, en_US.utf8, or similar
        return 1 if 0 <= index($ENV{$_}, 'UTF-8') || 0 <= index($ENV{$_}, 'utf8');
    }
    return 0;
}

1;
