package body mem_init is

    impure function InitRamFromFile(RamFileName : in string; RamDepth : in natural) return word_array is

        FILE RamFile : text open read_mode is RamFileName;
    
        variable RamFileLine : line;    
        variable RAM         : word_array(0 to RamDepth-1);
        variable mem         : bit_vector(data_width-1 downto 0);

        begin

            for i in 0 to RamDepth-1 loop
                readline(RamFile, RamFileLine);
                read(RamFileLine, mem);
                RAM(i) := word(to_stdlogicvector(mem));
            end loop ;

        return RAM;

        end function;

end package body mem_init;

