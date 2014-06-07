package Kwim;
$Kwim::VERSION = '0.0.7';
use Pegex::Parser;
use Kwim::Grammar;

sub kwim_to_byte {
    require Kwim::Byte;
}

1;
