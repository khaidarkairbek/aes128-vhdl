----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: AddRoundKey for AES - Testbench
-- Project Name: AES Algorithm Implementation
-- Target Device: Basys 3
-- Description: Advanced Encryption Standard (AES) based on Rijndael algorithm
-- Algorithm design specified at https://doi.org/10.6028/NIST.FIPS.197-upd1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
library work; 
use work.state_pkg.all;

ENTITY AddRoundKey_tb IS
END AddRoundKey_tb;

ARCHITECTURE testbench OF AddRoundKey_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT AddRoundKey
    PORT(
        state_in : in state_matrix; 
        en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic; 
        w : in round_keys; 
        round : in natural range 0 to 10;
        done : out std_logic;  
        state_out : out state_matrix);
    END COMPONENT;
    
    COMPONENT KeyExpansion
    PORT(
        key : in std_logic_vector(0 to 127);
        en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic;
        done : out std_logic;
        w : out round_keys);
    END COMPONENT;
---------------------------
--Inputs
---------------------------
	signal state_in : state_matrix := (others => (others => (others => '0'))); 
    signal round : natural := 0; 
    signal w : round_keys := (others => (others => '0'));
    signal key : std_logic_vector(127 downto 0) := (others => '0');  
    signal key_en, en : std_logic := '0'; 
    signal clk : std_logic := '0'; 
    signal reset : std_logic := '0'; 
    signal done, key_done : std_logic := '0'; 
    constant clk_period : time := 100 ns; -- 10MHz
---------------------------
--Outputs
---------------------------
    signal state_out : state_matrix; 

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: AddRoundKey 
    PORT MAP (
        state_in => state_in,
        en => en, 
        clk => clk, 
        reset => reset, 
        w => w,
        round => round,
        done => done, 
        state_out => state_out);
    
---------------------------
--Instantiate uut
---------------------------
    key_generator: KeyExpansion 
    PORT MAP (
        key => key,
        en => key_en, 
        reset => reset, 
        clk => clk,
        done => key_done,
        w => w);
        
    clk_process: process 
    begin
        clk <= not clk;
        wait for clk_period/2;  
    end process;
    

---------------------------
--Stimulus process
---------------------------
    stim_proc: process
    begin        
        wait for clk_period; 
        key <= x"2b7e151628aed2a6abf7158809cf4f3c";
        wait for 10 * clk_period; 
        key_en <= '1'; 
        wait for 10 * clk_period;
        state_in <= (
            (x"32", x"88", x"31", x"e0"), 
            (x"43", x"5a", x"31", x"37"), 
            (x"f6", x"30", x"98", x"07"), 
            (x"a8", x"8d", x"a2", x"34")
        );
        wait for 10 * clk_period;
        en <= '1';
        -------------------------------
        ---    Expected state out   ---
        ---    19 - a0 - 9a - e9    ---
        ---    3d - f4 - c6 - f8    ---
        ---    e3 - e2 - 8d - 48    ---
        ---    be - 2b - 2a - 08    ---
        -------------------------------
        wait; 
    end process;

END testbench;