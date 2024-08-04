----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: ShiftRows for AES - Behavioral
-- Project Name: AES Algorithm Implementation
-- Target Device: Basys 3
-- Description: Advanced Encryption Standard (AES) based on Rijndael algorithm
-- Algorithm design specified at https://doi.org/10.6028/NIST.FIPS.197-upd1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.state_pkg.all;

entity ShiftRows is
    Port ( 
        state_in : in state_matrix; 
        en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic;
        done : out std_logic;
        state_out : out state_matrix);
end ShiftRows;

architecture Behavioral of ShiftRows is

begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                done <= '0'; 
            elsif en = '1' then 
                for r in 0 to 3 loop
                    for c in 0 to 3 loop
                         state_out(r, c) <= state_in(r, (r + c) mod 4); 
                    end loop;  
                end loop;
                done <= '1'; 
            else  
                done <= '0';  
            end if;  
        end if; 
    end process; 

end Behavioral;