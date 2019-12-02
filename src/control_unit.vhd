library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

--! 	Instruction decoding and control unit.
--!	Decodes incoming instructions and sets control signals accordingly.
entity control_unit is
	port(
		-- Inputs, indices correspond to instruction word indices:
		instr_type  : in instruction_type; --! Instruction opcode field.
		funct3  : in std_logic_vector( 2 downto 0); --! Instruction @c funct3 field.
		func  : in std_logic_vector( 6 downto 4); --! Instruction @c func field.
        
		-- Control signals:
		rd_write            : out std_logic;   --! Signals that the instruction writes to a destination register.
		branch              : out branch_type; --! Signals that the instruction is a branch.

		-- Sources of operands to the ALU:
		alu_src1, alu_src2 : out alu_operand_source; --! ALU operand source.

		-- ALU operation:
		alu_op : out alu_operation; --! ALU operation to perform for the instruction.
        
        branch_op : out branch_operation ;       

        mem_op   : out memory_operation_type --! Memory operation to perform for the instruction.            
    
	);
end control_unit;

--! @brief Behavioural description of the instruction decoding and control unit.
architecture behaviour of control_unit is

begin
	
mem_op <= MEMOP_TYPE_STORE when instr_type = st else
          MEMOP_TYPE_LOAD when instr_type = ld else   
          MEMOP_TYPE_NONE ;  

	--! @brief   ALU control unit.
--! @details Decodes arithmetic and logic instructions and sets the
	--!          control signals relating to the ALU.
	alu_control: entity work.alu_control_unit
		port map(
			instr_type => instr_type,
			funct3 => funct3,
			func => func,
			alu_src1 => alu_src1,
			alu_src2 => alu_src2,
			alu_op => alu_op,
            branch_op => branch_op
		);

	--! Decodes instructions.
	decode_ctrl: process(instr_type, funct3)
	begin
		case instr_type is
			when ui => -- Load upper immediate
				rd_write <= '1';
				branch <= BRANCH_NONE;
            when auipc => -- Add upper immediate to PC
				rd_write <= '1';
				branch <= BRANCH_NONE;
			when jal => -- Jump and link
				rd_write <= '1';
				branch <= BRANCH_JUMP;
			when jalr => -- Jump and link register
				rd_write <= '1';
				branch <= BRANCH_JUMP_INDIRECT;
			when br => -- Branch operations
				rd_write <= '0';
				branch <= BRANCH_CONDITIONAL;
			when st => -- Store instructions
				rd_write <= '0';
				branch <= BRANCH_NONE;
			when im | ld | reg => -- Register-immediate operations
				rd_write <= '1';
				branch <= BRANCH_NONE;
     		when others =>
				rd_write <= '0';
				branch <= BRANCH_NONE;
		end case;
	end process decode_ctrl;

end architecture behaviour;
