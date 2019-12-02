library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.utilities.all;

entity execute is
	port(
		clk,reset,flush : in std_logic;

		-- Data memory outputs:
		dmem_address   : out mem_address;
		dmem_data_out  : out signed_word;
		dmem_write : out std_logic;

		-- Register addresses:
		rs1_addr_in, rs2_addr_in, rd_addr_in : in  register_address;
		rd_addr_out                          : out register_address;

		-- Register values:
		rs1_data, rs2_data,immediate_in : in signed_word;
		rd_data_out              : out signed_word;

		-- Instruction address:
		pc_in     : in  mem_address;
		pc_out    : out mem_address;

		-- Control signals:
	    branch_op_in : in branch_operation;
		alu_op_in    : in  alu_operation;
		alu_x_src_in,alu_y_src_in : in  alu_operand_source;
		rd_write_in  : in  std_logic;
		rd_write_out : out std_logic;
		branch_in    : in  branch_type;
		branch_out   : out branch_type;

		-- Memory control signals:
		mem_op_in    : in  memory_operation_type;
		mem_op_out   : out memory_operation_type;

		-- Control outputs:
		jump       : out std_logic;
		jump_target : out mem_address;

		mem_rd_write,   wb_rd_write,    reg_rd_write          : in std_logic;
		mem_rd_addr,    wb_rd_addr,     reg_rd_addr           : in register_address;
		mem_rd_value,   wb_rd_value,    reg_rd_value          : in signed_word

	);
end execute;

architecture behaviour of execute is 
	signal alu_op : alu_operation;
	signal branch_op:branch_operation;  
	signal alu_x_src, alu_y_src : alu_operand_source;

	signal alu_x, alu_y, alu_result : signed_word;

	signal rs1_addr, rs2_addr : register_address;

	signal mem_op : memory_operation_type;
	
	signal pc        : mem_address;
	signal immediate : signed_word;
	signal funct3    : std_logic_vector(2 downto 0);

	signal rs1_forwarded, rs2_forwarded : signed_word;

	signal branch : branch_type;

	signal branch_condition : std_logic;

begin

	rd_data_out <= alu_result;

	branch_out <= branch;

	mem_op_out <= mem_op;

	pc_out <= pc;

	jump <= (to_std_logic(branch = BRANCH_JUMP_INDIRECT) or (to_std_logic(branch = BRANCH_CONDITIONAL) and branch_condition));
		
	dmem_address <= mem_address(alu_result(mem_add_width-1 downto 0)) ;
	dmem_data_out <= rs2_forwarded;
	dmem_write <= '1' when mem_op = MEMOP_TYPE_STORE else '0';

	pipeline_register: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' or flush = '1' then
				rd_write_out <= '0';
				branch <= BRANCH_NONE;
				mem_op <= MEMOP_TYPE_NONE;
			else
				pc <= pc_in;
				-- Register signals:
				rd_write_out <= rd_write_in;
				rd_addr_out <= rd_addr_in;
				rs1_addr <= rs1_addr_in;
				rs2_addr <= rs2_addr_in;

				-- ALU signals:
				alu_op <= alu_op_in;
				alu_x_src <= alu_x_src_in;
				alu_y_src <= alu_y_src_in;
			    branch_op <= branch_op_in;

				-- Control signals:
				branch <= branch_in;
				mem_op <= mem_op_in;

				-- Constant values:
				immediate <= immediate_in;
				
			end if;
		end if;
	end process pipeline_register;

	calc_jump_tgt: process(branch, pc, rs1_forwarded, immediate)
	begin
		case branch is
			when BRANCH_CONDITIONAL =>
				jump_target <= mem_address(unsigned(pc) + unsigned(immediate(mem_add_width-1 downto 0)));
			when BRANCH_JUMP_INDIRECT =>
				jump_target <= mem_address(unsigned(rs1_forwarded(mem_add_width-1 downto 0)) + unsigned(immediate(mem_add_width-1 downto 0)));
			when others =>
				jump_target <= (others => '0');
		end case;
	end process calc_jump_tgt;

	alu_x_mux: entity work.alu_mux
		port map(
			source => alu_x_src,
			register_value => rs1_forwarded,
			immediate_value => immediate,
			pc_value => pc,
			output => alu_x
		);

	alu_y_mux: entity work.alu_mux
		port map(
			source => alu_y_src,
			register_value => rs2_forwarded,
			immediate_value => immediate,
			pc_value => pc,
			output => alu_y
		);

	alu_x_forward: process(reg_rd_write, reg_rd_value, reg_rd_addr,mem_rd_write, mem_rd_value, mem_rd_addr, rs1_addr,
		rs1_data, wb_rd_write, wb_rd_addr, wb_rd_value)
	begin
        if mem_rd_write = '1' and mem_rd_addr = rs1_addr and mem_rd_addr /= b"00000" then
			rs1_forwarded <= mem_rd_value;
		elsif wb_rd_write = '1' and wb_rd_addr = rs1_addr and wb_rd_addr /= b"00000" then
			rs1_forwarded <= wb_rd_value;
        elsif reg_rd_write = '1' and reg_rd_addr = rs1_addr and reg_rd_addr /= b"00000" then
			rs1_forwarded <= reg_rd_value;
		else
			rs1_forwarded <= rs1_data;
		end if;
	end process alu_x_forward;

	alu_y_forward: process(reg_rd_write, reg_rd_value, reg_rd_addr,mem_rd_write, mem_rd_value, mem_rd_addr, rs2_addr,
		rs2_data, wb_rd_write, wb_rd_addr, wb_rd_value)
	begin
		if mem_rd_write = '1' and mem_rd_addr = rs2_addr and mem_rd_addr /= b"00000" then
			rs2_forwarded <= mem_rd_value;
		elsif wb_rd_write = '1' and wb_rd_addr = rs2_addr and wb_rd_addr /= b"00000" then
			rs2_forwarded <= wb_rd_value;
        elsif reg_rd_write = '1' and reg_rd_addr = rs2_addr and reg_rd_addr /= b"00000" then
            rs2_forwarded <= reg_rd_value;    
		else
			rs2_forwarded <= rs2_data;
		end if;
	end process alu_y_forward;

	alu_instance: entity work.alu
		port map(
	  inp(0) => alu_x,
      inp(1) => alu_y,  
      alu_op => alu_op,
      branch_op => branch_op,  
      result => alu_result,
      flag => branch_condition
);

end behaviour;
