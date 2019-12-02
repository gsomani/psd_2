library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity alu_control_unit is
	port(
		instr_type  : in instruction_type;
		funct3  : in std_logic_vector(2 downto 0);
		func  : in std_logic_vector(6 downto 4);
		
		-- Sources of ALU operands:
		alu_src1, alu_src2 : out alu_operand_source;

		-- ALU operation:
		alu_op : out alu_operation;

        branch_op : out branch_operation
	);
end alu_control_unit;

architecture behaviour of alu_control_unit is

signal f3,f7:integer;
signal al_op :alu_operation;

begin

    f3 <= to_integer(unsigned(funct3));
    f7 <= to_integer(unsigned(func(6 downto 4)));    

    alu_op <= al_op when instr_type = im or instr_type= reg else
              alu_add;    

    decode_alu_op:process(instr_type, f3, f7)
	begin
        case f3 is
                    when 0 =>
						if f7 = 0 or instr_type = im then
							al_op <= alu_add;
						else
							al_op <= alu_sub;
						end if;
                        branch_op <= beq;
					when 1 =>
						al_op <= alu_sll;
                        branch_op <= bne;
					when 2 =>
						al_op <= alu_slt;
                        branch_op <= beq;
					when 3 =>
						al_op <= alu_sltu;
                        branch_op <= beq;    
					when 4 =>
						al_op <= alu_xor;
                        branch_op <= blt;
					when 5 =>
						if f7 = 0 then
							al_op <= alu_srl;
						else
							al_op <= alu_sra;
						end if;
                        branch_op <= bge;
					when 6 =>
						al_op <= alu_or;
                        branch_op <= bltu;
					when 7 =>
						al_op <= alu_and;
                        branch_op <= bgeu;
					when others =>
						al_op <= alu_add;
                        branch_op <= beq;    
				end case; 
    end process;

	decode_alu_src: process(instr_type)
	begin
        
        case instr_type is
			when ui => -- Load upper immediate
				alu_src1 <= ALU_SRC_NULL;
				alu_src2 <= ALU_SRC_IMM;
            when auipc => -- Add upper immediate to PC
				alu_src1 <= ALU_SRC_PC;
				alu_src2 <= ALU_SRC_IMM;
			when jal | jalr => -- Jump and link
				alu_src1 <= ALU_SRC_PC_NEXT;
				alu_src2 <= ALU_SRC_NULL;
			when br | reg => -- Branch and register-register operations
				alu_src1 <= ALU_SRC_REG;
				alu_src2 <= ALU_SRC_REG;
			when ld | st => -- Load or store instruction
				alu_src1 <= ALU_SRC_REG;
				alu_src2 <= ALU_SRC_IMM;
			when im => -- Register-immediate operations
				alu_src1 <= ALU_SRC_REG;
                alu_src2 <= ALU_SRC_IMM;				
		    when others =>
				alu_src1 <= ALU_SRC_REG;
				alu_src2 <= ALU_SRC_REG;
		end case;
	end process decode_alu_src;

end behaviour;
