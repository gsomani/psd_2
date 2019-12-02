library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.types.all;

entity tb_cpu is
end tb_cpu;

architecture arch of tb_cpu is

component cpu is
    port( clk,reset,sw:in std_logic;  
          led:out std_logic_vector(15 downto 0));
end component;	

constant period:time:= 10 ns;

signal clk,reset,sw:std_logic;
signal led:std_logic_vector(15 downto 0);

begin

cp:cpu 
port map( clk =>clk ,reset => reset,sw => sw,led => led);

process
begin
    wait for 20 ns;
    cloop: loop
        clk <= '0';
        wait for (period/2);
        clk <= '1';
        wait for (period/2);
    end loop;
end process;

process
begin
    wait for 20 ns;
    reset<='1';sw<='0';
    wait for 100 ns;
    reset <= '0';
    wait for 5000 ns;
    sw<='1';        
    wait;
end process;

end arch;

