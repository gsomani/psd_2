library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

--! 32-bit RISC-V register file.
entity register_file is
	port(
		clk,reset    : in std_logic;

		-- Read port 1:
		rs1_addr : in  register_address;
		rs1_data : out signed_word;

		-- Read port 2:
		rs2_addr : in  register_address;
		rs2_data : out signed_word;

		-- Write port:
		rd_addr  : in register_address;
		rd_data  : in signed_word;
		rd_write : in std_logic;

        rd_addr_out  : out register_address;
		rd_data_out  : out signed_word;
		rd_write_out : out std_logic;
        
        	a0:out word
	);
end register_file;

architecture behaviour of register_file is

signal reg: signed_array(0 to reg_file_depth-1);

begin

process(clk,rd_write,rs1_addr,rs2_addr,rd_addr,reg)
  begin
    reg(0) <= X"00000000"; 
    if (clk'event and clk='1') then
      if(reset = '1') then
           reg <= (others => x"00000000");
      elsif (rd_write = '1' and rd_addr /= "00000") then
           reg(to_integer(rd_addr)) <= rd_data;
      end if;
      rs1_data <= reg(to_integer(rs1_addr));
      rs2_data <= reg(to_integer(rs2_addr)); 
    end if; 
end process;     

a0 <= word(reg(10));
	
register_rd_address: process(clk)
    begin
		if rising_edge(clk) then
			if reset = '1' then
				rd_write_out <= '0';
			else
				rd_data_out <= rd_data;
				rd_addr_out <= rd_addr;
				rd_write_out <= rd_write;
			end if;
		end if;
    end process;

end behaviour;

