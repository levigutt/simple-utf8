package C;
use strict;
use Encode ();
use Filter::Simple;

our $UNICODE  = 95; # defaults to -CSDL
our $OPEN;
our $SET_UTF8 = 1;
our $ENCODING = ':encoding(UTF-8)';


# process version as option
sub VERSION
{
    my (undef, $option) = @_;
    $UNICODE = _process_args($option);
}

sub import
{
    my (undef, $option) = @_;
    $UNICODE  = _process_args($option) if defined $option;
    $SET_UTF8 = !($UNICODE & 64) || !!${^UTF8LOCALE};

    if( $SET_UTF8 )
    {
        $UNICODE &  1 and binmode STDIN,  $ENCODING;
        $UNICODE &  2 and binmode STDOUT, $ENCODING;
        $UNICODE &  4 and binmode STDERR, $ENCODING;
        if( '-e' eq $0 )
        {
            require "open.pm";
            open::import(IN  => $ENCODING) if $UNICODE & 8;
            open::import(OUT => $ENCODING) if $UNICODE & 16;
        }
        $UNICODE & 32 and @ARGV = map { Encode::decode 'UTF-8', $_, Encode::FB_CROAK } @ARGV;
        $OPEN = "$ENCODING\0$ENCODING";
    }
    $UNICODE & 128 and utf8::decode($_) for @ARGV;
    $UNICODE & 256 and ${^UTF8CACHE} = -1;
}

FILTER
{
    if( $SET_UTF8 )
    {
        $_ = "use open IN  => '$ENCODING';" . $_ if $UNICODE & 8;
        $_ = "use open OUT => '$ENCODING';" . $_ if $UNICODE & 16;
    }
};

sub _process_args
{
    my ($option) = @_;
    my $flags;
    if( $option =~ /^\d+$/ )
    {
        $flags = 0+$option;
        my $invalid = $flags & ~511;
        warn "Unknown Unicode option value $invalid.\n" and exit 29 if $invalid;
    }
    else
    {
        $flags = 0;
        my %letters = (     I => 1      # STDIN
                      ,     O => 2      # STDOUT
                      ,     E => 4      # STDERR
                      ,     S => 7      # I + O + E
                      ,     i => 8      # input stream default
                      ,     o => 16     # output stream default
                      ,     D => 24     # i + o
                      ,     A => 32     # @ARGV
                      ,     L => 64     # conditional IOEioA
                     #,     W => 128    # ...
                      ,     a => 256    # debug mode for UTF-8 caching
                      );
        for (split//,$option)
        {
            unless( exists $letters{$_} )
            {
                warn "Unknown Unicode option letter '$_'.\n" and exit 29;
            }
            $flags |= $letters{$_};
        }
    }
    return $flags;
}

1;
