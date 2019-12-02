library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity writeback is
	port(
		clk    : in std_logic;
		reset  : in std_logic;

		-- Destination register interface:
		rd_addr_in   : in  register_address;
		rd_addr_out  : out register_address;
		rd_write_in  : in  std_logic;
		rd_write_out : out std_logic;
		rd_data_in   : in  signed_word;
		rd_data_out  : out signed_word
	);
end entity writeback;

architecture behaviour of writeback is
begin

	pipeline_register: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				rd_write_out <= '0';
			else
				rd_data_out <= rd_data_in;
				rd_write_out <= rd_write_in;
				rd_addr_out <= rd_addr_in;
			end if;
		end if;
	end process pipeline_register;

end behaviour;
