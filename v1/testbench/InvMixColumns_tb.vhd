----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvMixColumns for AES - Testbench
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

ENTITY InvMixColumns_tb IS
END InvMixColumns_tb;

ARCHITECTURE testbench OF InvMixColumns_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT InvMixColumns
    Port ( 
        state_in : in state_matrix; 
        en : in std_logic;
        reset : in std_logic; 
        clk : in std_logic; 
        done : out std_logic; 
        state_out : out state_matrix);
    end component;
    
---------------------------
--Inputs
---------------------------
	signal state_in : state_matrix := (others => (others => (others => '0')));  
	signal en : std_logic := '0'; 
	signal clk : std_logic := '0'; 
	constant clk_period : time := 100ns; 
	signal reset : std_logic := '0'; 

---------------------------
--Outputs
---------------------------
    signal state_out : state_matrix; 
    signal done : std_logic; 

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: InvMixColumns 
    PORT MAP (
        state_in => state_in,
        en => en,
        reset => reset, 
        clk => clk, 
        done => done,
        state_out => state_out);
    
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
        wait for 10 * clk_period;
        state_in <= (
            (x"47", x"40", x"a3", x"4c"), 
            (x"37", x"d4", x"70", x"9f"), 
            (x"94", x"e4", x"3a", x"42"), 
            (x"ed", x"a5", x"a6", x"bc")
        );
        wait for 20 * clk_period;
        en <= '1';
        -------------------------------
        ---    Expected state out   ---
        ---    87 - f2 - 4d - 97    ---
        ---    6e - 4c - 90 - ec    ---
        ---    46 - e7 - 4a - c3    ---
        ---    a6 - 8c - d8 - 95    ---
        -------------------------------
        wait for 5 * clk_period; 
        reset <= '1'; 
        wait;
    end process;

END testbench;
