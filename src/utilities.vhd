library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package utilities is

	--! Converts a boolean to an std_logic.
	function to_std_logic(input : in boolean) return std_logic;

end package utilities;

