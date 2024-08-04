----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: Key Expansion for AES - Behavioral
-- Project Name: AES Algorithm Implementation
-- Target Device: Basys 3
-- Description: Advanced Encryption Standard (AES) based on Rijndael algorithm
-- Algorithm design specified at https://doi.org/10.6028/NIST.FIPS.197-upd1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work; 
use work.state_pkg.all; 

entity KeyExpansion is
    Port ( 
        key : in std_logic_vector(0 to 127);
        en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic;
        done : out std_logic;
        w : out round_keys);
end KeyExpansion;

architecture Behavioral of KeyExpansion is

signal output_reg : round_keys := (others => (others => '0'));
signal done_reg : std_logic := '0'; 
signal current_round : integer range 0 to 10 := 0;

function rot_word(
    a : in round_key) 
    return std_logic_vector is
    variable result : round_key; 
begin
    result(31 downto 24) := a(23 downto 16); 
    result(23 downto 16) := a(15 downto 8); 
    result(15 downto 8) := a(7 downto 0); 
    result(7 downto 0) := a(31 downto 24);  
    return result;
end function;

function sub_word(
    a : in std_logic_vector(31 downto 0)) 
    return std_logic_vector is 
    variable result : std_logic_vector(31 downto 0);
    type sbox_type is array (0 to 255) of std_logic_vector(7 downto 0);
    constant sbox : sbox_type := (
		-- Row 0
        x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
        -- Row 1
        x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
        -- Row 2
        x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
        -- Row 3
        x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
        -- Row 4
        x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
        -- Row 5
        x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
        -- Row 6
        x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
        -- Row 7
        x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
        -- Row 8
        x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
        -- Row 9
        x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
        -- Row a
        x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
        -- Row b
        x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
        -- Row c
        x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
        -- Row d
        x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
        -- Row e
        x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
        -- Row f
        x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16"
    );
begin 
    for i in 0 to 3 loop
        result(8*i+7 downto 8*i) := sbox(to_integer(unsigned(a(8*i+7 downto 8*i))));
    end loop;
    return result;
end function;

type round_constant is array (1 to 10) of std_logic_vector(31 downto 0);
    
constant Rcon : round_constant := (
    x"01000000", 
    x"02000000", 
    x"04000000", 
    x"08000000", 
    x"10000000", 
    x"20000000", 
    x"40000000", 
    x"80000000", 
    x"1b000000", 
    x"36000000"
);

begin
    process(clk)
    begin
        if rising_edge(clk) then
           if reset = '1' then 
                current_round <= 0; 
                done_reg <= '0'; 
           elsif en = '1' or current_round /= 0 then 
                case current_round is 
                    when 0 => 
                        for i in 0 to 3 loop
                            output_reg(i) <= key(32 * i to 32 * i + 31); 
                        end loop; 
                    when 1 to 10 => 
                        for i in 0 to 3 loop
                                output_reg(current_round * 4) <= output_reg(current_round * 4 - 4) xor sub_word(rot_word(output_reg(current_round * 4 - 1))) xor Rcon(current_round);
                                output_reg(current_round * 4 + 1) <= output_reg(current_round * 4 - 3) xor (output_reg(current_round * 4 - 4) xor sub_word(rot_word(output_reg(current_round * 4 - 1))) xor Rcon(current_round));
                                output_reg(current_round * 4 + 2) <= output_reg(current_round * 4 - 2) xor (output_reg(current_round * 4 - 3) xor (output_reg(current_round * 4 - 4) xor sub_word(rot_word(output_reg(current_round * 4 - 1))) xor Rcon(current_round)));
                                output_reg(current_round * 4 + 3) <= output_reg(current_round * 4 - 1) xor (output_reg(current_round * 4 - 2) xor (output_reg(current_round * 4 - 3) xor (output_reg(current_round * 4 - 4) xor sub_word(rot_word(output_reg(current_round * 4 - 1))) xor Rcon(current_round))));
                            
                        end loop;
                       
                   when others => null;  
               end case; 
               if current_round = 10 then 
                    current_round <= 0; 
                    done_reg <= '1'; 
               else
                    current_round <= current_round + 1;
               end if;
           else
                done_reg <= '0'; 
                current_round <= 0; 
           end if;
        end if;  
    
    end process;  
    w <= output_reg; 
    done <= done_reg; 

end Behavioral;
