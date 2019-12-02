library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
    
    constant instr_rom_depth :integer := 512;
    constant data_ram_depth :integer := 512;
    constant data_width :integer := 32;
    constant offset_width :integer := 12;
    constant ui_width :integer := 12;
    constant reg_add_width :integer := 5;
    constant instr_width :integer := 32;
    constant pc_width :integer := 12;
    constant mem_add_width :integer := 12;
    constant opcode_width :integer := 7;
    constant reg_file_depth :integer := 32;        


    subtype word is std_logic_vector(data_width-1 downto 0);        
    subtype signed_word is signed(data_width-1 downto 0);
    subtype unsigned_word is unsigned(data_width-1 downto 0);

    constant RISCV_NOP : word := (31 downto 5 => '0') & "10011"; -- ADDI x0, x0, 0
    
    subtype mem_address is unsigned(mem_add_width-1 downto 0);
    constant RESET_ADDRESS : mem_address := x"000"; --! Address of the first instruction to execute.    

    subtype register_address is unsigned(reg_add_width-1 downto 0);

    subtype signed_offset is signed(offset_width-1 downto 0);
    
    type word_array is array (NATURAL range <>) of word;
    type unsigned_array is array (NATURAL range <>) of unsigned_word;
    type signed_array is array (NATURAL range <>) of signed_word;

    type alu_operation is (alu_add,alu_sub,alu_sll,alu_slt,alu_sltu,alu_xor,alu_srl,alu_sra,alu_or,alu_and);
        
    type branch_operation is (beq,bne,blt,bge,bltu,bgeu);       
    
    type instruction_type is (reg,im,ld,st,br,ui,jal,jalr,auipc,none);   

	--! Types of branches.
	type branch_type is (
			BRANCH_NONE, BRANCH_JUMP, BRANCH_JUMP_INDIRECT, BRANCH_CONDITIONAL, BRANCH_SRET
		);

	--! Source of an ALU operand.
	type alu_operand_source is (
			ALU_SRC_REG, ALU_SRC_IMM, ALU_SRC_PC, ALU_SRC_PC_NEXT, ALU_SRC_NULL
		);

	--! Type of memory operation:
	type memory_operation_type is (
			MEMOP_TYPE_NONE, MEMOP_TYPE_LOAD, MEMOP_TYPE_STORE
		);

end package types;
