----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: MixColumbs for AES - Behavioral
-- Project Name: AES Algorithm Implementation
-- Target Device: Basys 3
-- Description: Advanced Encryption Standard (AES) based on Rijndael algorithm
-- Algorithm design specified at https://doi.org/10.6028/NIST.FIPS.197-upd1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.state_pkg.all;

entity MixColumns is
    Port ( 
        state_in : in state_matrix; 
        en : in std_logic;
        reset : in std_logic; 
        clk : in std_logic; 
        done : out std_logic; 
        state_out : out state_matrix);
end MixColumns;

architecture Behavioral of MixColumns is

-- Galois field multiplication by {02}
function gf_mult_by2(a : std_logic_vector(7 downto 0)) return std_logic_vector is
    variable result : std_logic_vector(7 downto 0);
begin
    if a(7) = '0' then 
        result := a(6 downto 0) & '0'; 
    else 
        result := (a(6 downto 0) xor "0001101") & '1'; 
    end if; 
    return result;
end function;

-- Galois field multiplication by {03} => {00000011} = {02} xor {01} => a * {03} = a * {02} xor a * {01}
function gf_mult_by3(a : std_logic_vector(7 downto 0)) return std_logic_vector is 
    variable result : std_logic_vector(7 downto 0); 
begin
    result := gf_mult_by2(a) xor a;
    return result;
end function;

begin 
    
    process(clk)
    begin
       if rising_edge(clk) then 
            if reset = '1' then 
                done <= '0'; 
            elsif en = '1' then 
                for c in 0 to 3 loop
                    state_out(0, c) <= gf_mult_by2(state_in(0, c)) xor gf_mult_by3(state_in(1, c)) xor state_in(2, c) xor state_in(3, c); 
                    state_out(1, c) <= state_in(0, c) xor gf_mult_by2(state_in(1, c)) xor gf_mult_by3(state_in(2, c)) xor state_in(3, c); 
                    state_out(2, c) <= state_in(0, c) xor state_in(1, c) xor gf_mult_by2(state_in(2, c)) xor gf_mult_by3(state_in(3, c)); 
                    state_out(3, c) <= gf_mult_by3(state_in(0, c)) xor state_in(1, c) xor state_in(2, c) xor gf_mult_by2(state_in(3, c));
                end loop; 
                
                done <= '1'; 
            else
                done <= '0'; 
            end if; 
        end if; 
    end process; 

end Behavioral;