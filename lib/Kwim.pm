# ABSTRACT: Known What I Mean
package Kwim;
$Kwim::VERSION = '0.0.2';
use Pegex::Parser;
use Kwim::Grammar;

sub kwim_to_byte {
    require Kwim::Byte;
}

1;
