library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.types.all;

package mem_init is   

    impure function InitRamFromFile(RamFileName : in string; RamDepth : in natural) return word_array;

end package mem_init;

