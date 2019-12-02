library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.mem_init.all;

entity cpu is
	port(
	-- Control inputs:
		clk,reset,sw       : in std_logic; --! Processor clock
		led : out std_logic_vector(15 downto 0)
);
end cpu;

architecture Behavioral of cpu is

	signal imem: word_array(0 to instr_rom_depth-1 ) := InitRamFromFile("memory.mem",instr_rom_depth);
    signal dmem: signed_array(0 to data_ram_depth-1 ) := (others => x"00000000");
    signal pc_add,read_mem_add,write_mem_add: unsigned(mem_add_width-2 downto 2);
    signal a0:word;    

    -- Instruction memory interface:
		signal imem_address : mem_address; --! Address of the next instruction
		signal imem_data : word; --! Instruction input

		-- Data memory interface:
		signal dmem_address   : mem_address; --! Data address
		signal data_in   : signed_word; --! Input from the data memory
		signal data_out  : signed_word; --! Ouptut to the data memory
		signal we : std_logic;


component core is
	port(
		-- Control inputs:
		clk       : in std_logic; --! Processor clock
		reset     : in std_logic; --! Reset signal
		
		-- Instruction memory interface:
		imem_address : out mem_address; --! Address of the next instruction
		imem_data_in : in word; --! Instruction input

		-- Data memory interface:
		dmem_address   : out mem_address; --! Data address
		dmem_data_in   : in signed_word; --! Input from the data memory
		dmem_write : out std_logic;
		dmem_data_out  : out signed_word; --! Ouptut to the data memory
		a0:out word
		);
end component;

begin

    pc_add <= imem_address(pc_width-2 downto 2);
    read_mem_add <= dmem_address(mem_add_width-2 downto 2);
    write_mem_add <= dmem_address(mem_add_width-2 downto 2);
    
    imem_ram:process(clk)
    begin
       if (clk'event and clk='1') then
            imem_data <= imem(to_integer(pc_add)) ; 
        end if;
    end process;
     
    dmem_ram:process(clk)
    begin
       if (clk'event and clk='1') then
            if (we='1') then
                dmem(to_integer(write_mem_add)) <= data_in;
            end if;
            data_out <= dmem(to_integer(read_mem_add));  
        end if;
    end process;
    
    led <= a0(15 downto 0) when sw='0' else
           a0(31 downto 16); 
    
    riscv_core: core port map ( clk => clk, reset => reset, imem_address => imem_address ,imem_data_in => imem_data, dmem_address => dmem_address,dmem_data_in => data_out,dmem_data_out => data_in,dmem_write => we,a0=>a0);

end Behavioral;
