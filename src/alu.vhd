library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity alu is
port( inp:in signed_array(0 to 1);
      alu_op:in alu_operation;
      branch_op:in branch_operation;  
      result: out signed_word;
      flag: out std_logic);
end alu;	

architecture arch of alu is

signal r_add,r_sub,r_xor,r_and,r_or,r_sll,r_srl,r_sra,r_slt,r_sltu:signed_word;
signal eq,lt,ltu:std_logic;
signal count:unsigned(4 downto 0);

begin
    
    count <= unsigned(inp(1)(4 downto 0));    
   
    r_add <= inp(0) + inp(1);
    r_sub <= inp(0) - inp(1);
    r_xor <= inp(0) xor inp(1);
    r_and <= inp(0) and inp(1);
    r_or  <= inp(0) or inp(1);
    r_sll <= inp(0) sll to_integer(count);
    r_srl <= inp(0) srl to_integer(count);
    r_sra <= shift_right(inp(0), to_integer(count));
    r_slt <= (0 => lt, others => '0'); 
    r_sltu <= (0 => ltu, others => '0');

    lt <= r_sub(data_width-1) when inp(0)(data_width-1) = inp(1)(data_width-1) else
          inp(0)(data_width-1);
    
    ltu <= r_sub(data_width-1) when inp(0)(data_width-1) = inp(1)(data_width-1) else
          inp(1)(data_width-1);  
    
    eq <= '1' when r_sub = x"0000" else
          '0' ;

    with alu_op select
        result <= r_add when alu_add,
                  r_sll when alu_sll,  
                  r_sra when alu_sra,  
                  r_sub when alu_sub,   
                  r_xor when alu_xor,
                  r_srl when alu_srl,
                  r_or  when alu_or,   
                  r_and when alu_and, 
                  x"00000000" when others;
    
    with branch_op select
          flag <= eq       when beq,
                  not eq   when bne,
                  lt       when blt,
                  not lt   when bge, 
                  ltu      when bltu,
                  not ltu  when bgeu,  
                  '0'      when others;
      
end arch;
