library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.mem_init.all;
use work.utilities.all;

entity core is
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
end entity core;

architecture behaviour of core is

	-- Branch targets:
	signal jal_target,branch_target : mem_address;
	signal jal,branch_taken : std_logic;

	-- Register file read ports:
	signal rs1_address, rs2_address     : register_address;
	signal rs1_data, rs2_data           : signed_word;

	-- Fetch stage signals:
	signal if_pc : mem_address;   
	signal if_instruction_ready  : std_logic;

	-- Decode stage signals:
	signal id_rd_address      : register_address;
	signal flush_id,id_rd_write        : std_logic;
	signal id_immediate       : signed_word;
	signal id_branch          : branch_type;
	signal id_alu_src1, id_alu_src2 : alu_operand_source;
	signal id_alu_op          : alu_operation;
	signal id_branch_op       : branch_operation;
	signal id_mem_op          : memory_operation_type;
	signal id_pc              : mem_address;
	
	-- Execute stage signals:
	signal ex_rd_address     : register_address;
	signal ex_rd_data        : signed_word;
	signal ex_rd_write       : std_logic;
	signal ex_pc             : mem_address;
	signal ex_branch         : branch_type;
	signal ex_mem_op         : memory_operation_type;

	-- Memory stage signals:
	signal mem_rd_write    : std_logic;
	signal mem_rd_address  : register_address;
	signal mem_rd_data     : signed_word;

	-- Writeback signals:
	signal wb_rd_address  : register_address;
	signal wb_rd_data     : signed_word;
	signal wb_rd_write    : std_logic;
    
    -- Register write signals:
	signal reg_rd_address  : register_address;
	signal reg_rd_data     : signed_word;
	signal reg_rd_write    : std_logic;
		
	signal imem: word_array(0 to instr_rom_depth-1 ) := InitRamFromFile("memory.mem",instr_rom_depth);
    signal dmem: word_array(0 to data_ram_depth-1 ) := (others=>x"00000000");
    signal pc_add,mem_add: unsigned(mem_add_width-2 downto 2);
    signal stall: std_logic;
	
begin
    
    stall <= not imem_data_in(0);  
    
    flush_id <=  jal or branch_taken; 
    
	------- Register file -------
	regfile: entity work.register_file
			port map(
				clk => clk,
                reset => reset,
				rs1_addr => rs1_address,
				rs2_addr => rs2_address,
				rs1_data => rs1_data,
				rs2_data => rs2_data,
				rd_addr => wb_rd_address,
				rd_data => wb_rd_data,
				rd_write => wb_rd_write,
                rd_addr_out => reg_rd_address,
				rd_data_out => reg_rd_data,
				rd_write_out => reg_rd_write,
                a0 => a0
			);

	------- Instruction Fetch (IF) Stage -------
	fetch: entity work.fetch
		 port map(
			clk => clk,
			reset => reset,
			imem_address => imem_address,
			stall => stall,
			branch => branch_taken,
            jal => jal,
            jal_target => jal_target,
			branch_target => branch_target,
			instruction_address => if_pc,
			instruction_ready => if_instruction_ready
		);	    
	
	------- Instruction Decode (ID) Stage -------
	decode: entity work.decode
	     port map(
			clk => clk,
			reset => reset,
			flush => flush_id,
			instruction_data => imem_data_in,
			instruction_address => if_pc,
			instruction_ready => if_instruction_ready,
			rs1_addr => rs1_address,
			rs2_addr => rs2_address,
			rd_addr => id_rd_address,
			immediate_out => id_immediate,
			rd_write => id_rd_write,
			branch => id_branch,
			alu_x_src => id_alu_src1,
			alu_y_src => id_alu_src2,
			alu_op => id_alu_op,
			branch_op => id_branch_op, 
			mem_op => id_mem_op,
            jump_and_link => jal,
            jal_target => jal_target,
			pc_out => id_pc
		);

	------- Execute (EX) Stage -------
	execute: entity work.execute
		port map(
			clk => clk,
			reset => reset,
			flush => branch_taken,
			dmem_address => dmem_address,
			dmem_data_out => dmem_data_out,
			dmem_write => dmem_write,
			rs1_addr_in => rs1_address,
			rs2_addr_in => rs2_address,
			rd_addr_in => id_rd_address,
			rd_addr_out => ex_rd_address,
			rs1_data => rs1_data,
			rs2_data => rs2_data,
			immediate_in => id_immediate,
			pc_in => id_pc,
			pc_out => ex_pc,
		    branch_op_in => id_branch_op,
    		alu_op_in => id_alu_op,
			alu_x_src_in => id_alu_src1,
			alu_y_src_in => id_alu_src2,
			rd_write_in => id_rd_write,
			rd_write_out => ex_rd_write,
			rd_data_out => ex_rd_data,
			branch_in => id_branch,
			branch_out => ex_branch,
			mem_op_in => id_mem_op,
			mem_op_out => ex_mem_op,
			jump => branch_taken,
			jump_target => branch_target,
			mem_rd_write => mem_rd_write,
			mem_rd_addr => mem_rd_address,
			mem_rd_value => mem_rd_data,
			wb_rd_write => wb_rd_write,
			wb_rd_addr => wb_rd_address,
			wb_rd_value => wb_rd_data,
            reg_rd_write => reg_rd_write,
			reg_rd_addr => reg_rd_address,
			reg_rd_value => reg_rd_data
		);

	------- Memory (MEM) Stage -------
	memory: entity work.memory
		port map(
			clk => clk,
			reset => reset,
			data_in => dmem_data_in,
			rd_write_in => ex_rd_write,
			rd_write_out => mem_rd_write,
			rd_data_in => ex_rd_data,
			rd_data_out => mem_rd_data,
			rd_addr_in => ex_rd_address,
			rd_addr_out => mem_rd_address,
			mem_op_in => ex_mem_op
		);	
 
	------- Writeback (WB) Stage -------
	writeback: entity work.writeback
		port map(
			clk => clk,
			reset => reset,
			rd_addr_in => mem_rd_address,
			rd_addr_out => wb_rd_address,
			rd_write_in => mem_rd_write,
			rd_write_out => wb_rd_write,
			rd_data_in => mem_rd_data,
			rd_data_out => wb_rd_data
		);
   
end architecture behaviour;
