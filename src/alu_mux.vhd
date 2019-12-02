library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

--! Multiplexer used to choose between ALU inputs.
entity alu_mux is
	port(
		source : in alu_operand_source;
		register_value,immediate_value: in signed_word;
        pc_value: in mem_address;
		output : out signed_word
	);
end entity alu_mux;

architecture behaviour of alu_mux is
signal pc,pc_next:integer;

begin

    pc <= to_integer(pc_value);
    pc_next <= pc + 4;
	mux: process(source, register_value, immediate_value,pc,pc_next)
	begin
		case source is
			when ALU_SRC_REG =>
				output <= register_value;
			when ALU_SRC_IMM =>
				output <= immediate_value;
            when ALU_SRC_PC =>
				output <= signed(to_signed(pc,32));
			when ALU_SRC_PC_NEXT =>
				output <= signed(to_signed(pc_next,32));
			when ALU_SRC_NULL =>
				output <= (others => '0');
		end case;
	end process mux;

end architecture behaviour;
