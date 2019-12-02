library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity imm_decoder is
	port(
		i_type : in instruction_type ;
        instruction : in std_logic_vector(instr_width-1 downto opcode_width);
		immediate   : out signed_word
	);
end imm_decoder;

architecture behaviour of imm_decoder is

signal imm:std_logic_vector(instr_width-1 downto 0);

begin

immediate <= signed(imm);

with i_type select

    imm <= instruction(31 downto 12) & (11 downto 0 => '0') when ui | auipc,
                (31 downto 20 => instruction(31)) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0' when jal,
                (31 downto 11 => instruction(31)) & instruction(30 downto 20) when im | ld | jalr, 
                (31 downto 11 => instruction(31)) & instruction(30 downto 25) & instruction(11 downto 7) when st,
				(31 downto 12 => instruction(31)) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0' when br,
                (others => '0') when others;

end behaviour;
