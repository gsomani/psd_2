library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

--! @brief Instruction fetch unit.
entity fetch is
	port(
		clk,reset  : in std_logic;

		-- Instruction memory connections:
		imem_address,instruction_address : out mem_address;

		-- Control inputs:
		stall,jal,branch    : in std_logic;

		jal_target,branch_target : in mem_address;

		-- Output to the instruction decode unit:
		instruction_ready   : out std_logic
	);
end entity fetch;

architecture behaviour of fetch is
	signal pc           : mem_address;
	signal pc_next      : mem_address;
	signal cancel_fetch : std_logic;
begin

	imem_address <= pc_next when cancel_fetch = '0' else pc;

	instruction_address <= pc;
   	instruction_ready <= not (stall or cancel_fetch);

	set_pc: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				pc <= RESET_ADDRESS;
			elsif branch = '1' or jal = '1' or cancel_fetch = '0' then
			    pc <= pc_next;
			end if;
            cancel_fetch <= reset;
		end if;
	end process set_pc;

	calc_next_pc: process(reset, stall, branch, jal, jal_target,branch_target, pc, cancel_fetch)
	begin
		if  branch = '1' then
			pc_next <= branch_target;
        elsif jal = '1' then
            pc_next <= jal_target;
		elsif (stall or cancel_fetch) = '0' then
		    pc_next <= mem_address(unsigned(pc) + 4);
		else
			pc_next <= pc;
		end if;
	end process calc_next_pc;

end architecture behaviour;
