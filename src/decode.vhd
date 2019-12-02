library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

--! @brief Instruction decode unit.
entity decode is
	port(
		clk,reset,flush : in std_logic;

		-- Register addresses:
		rs1_addr, rs2_addr, rd_addr : out register_address;

		-- Immediate value for immediate instructions:
		immediate_out : out signed_word;

		-- Control signals:
		rd_write          : out std_logic;
		branch            : out branch_type;
		alu_x_src,alu_y_src: out alu_operand_source;
		alu_op            : out alu_operation;
        branch_op         : out branch_operation ;       
		mem_op            : out memory_operation_type;
		
		-- Instruction address:
		pc_out,jal_target : out mem_address;
    
        jump_and_link: out std_logic;
		
		-- Instruction input:
		instruction_data    : in word;
		instruction_address : in mem_address;
		instruction_ready   : in std_logic	
	);

end decode;

architecture behaviour of decode is
	signal instruction   : word ;
    signal opcode:integer; 
    signal instr_type    :  instruction_type;
    signal pc : mem_address;
    signal immediate : signed_word;    

begin

    opcode <= to_integer(unsigned(instruction(6 downto 2)));
    pc_out <= pc;
    immediate_out <= immediate;

    with opcode select
    instr_type <=   reg when 12,
                    im when 4,
                    ld when 0,                
                    st when 8,
                    br when 24,
                    ui when 13,
                    jal when 27,
                    jalr when 25,
                    auipc when 5,
                    none when others;

	get_instruction: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				instruction <= RISCV_NOP;
				pc <= RESET_ADDRESS;
			elsif (flush = '1' or instruction_ready = '0') then
				instruction <= RISCV_NOP;
			else
				instruction <= instruction_data;
				pc <= instruction_address;
			end if;
		end if;
	end process get_instruction;

    jump_and_link <= '1' when instr_type = jal else '0';

    jal_target <= mem_address(unsigned(pc) + unsigned(immediate(mem_add_width-1 downto 0)));

	-- Extract register addresses from the instruction word:
	rs1_addr <= register_address(instruction(19 downto 15));
	rs2_addr <= register_address(instruction(24 downto 20));
	rd_addr  <= register_address(instruction(11 downto  7));

	-- Extract the immediate value from the instruction word:
	immediate_decoder: entity work.imm_decoder
		port map(
				i_type => instr_type,
                instruction => instruction(instr_width-1 downto opcode_width),
		        immediate => immediate
		);
	
	control_unit: entity work.control_unit
		port map(
			instr_type => instr_type,
			funct3 => instruction(14 downto 12),
			func => instruction(31 downto 29),
			rd_write => rd_write,
			branch => branch,
			alu_src1 => alu_x_src,
			alu_src2 => alu_y_src,
			alu_op => alu_op,
			mem_op => mem_op,
			branch_op => branch_op
		);

end behaviour;
