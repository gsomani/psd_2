library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity memory is
	port(
		clk    : in std_logic;
		reset  : in std_logic;

		-- Data memory inputs:
		data_in   : in signed_word;

		-- Destination register signals:
		rd_write_in  : in  std_logic;
		rd_write_out : out std_logic;
		rd_data_in   : in  signed_word;
		rd_data_out  : out signed_word;
		rd_addr_in   : in  register_address;
		rd_addr_out  : out register_address;

		-- Control signals:
		mem_op_in      : in  memory_operation_type
	
	);
end memory;

architecture behaviour of memory is
	signal mem_op   : memory_operation_type;
	signal rd_data : signed_word;
begin

	pipeline_register: process(clk)
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				rd_write_out <= '0';
				mem_op <= MEMOP_TYPE_NONE;
			else
				rd_data <= rd_data_in;
				rd_addr_out <= rd_addr_in;
				mem_op <= mem_op_in;
				rd_write_out <= rd_write_in;
			end if;
		end if;
	end process pipeline_register;

	rd_data_mux: process(rd_data, data_in, mem_op)
	begin
		if mem_op = MEMOP_TYPE_LOAD then
			rd_data_out <= data_in;
		else
			rd_data_out <= rd_data;
		end if;
	end process rd_data_mux;

end architecture behaviour;
