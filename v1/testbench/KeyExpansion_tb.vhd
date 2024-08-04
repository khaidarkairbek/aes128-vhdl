----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: KeyExpansion for AES - TestBench
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

ENTITY KeyExpansion_tb IS
END KeyExpansion_tb;

ARCHITECTURE testbench OF KeyExpansion_tb IS 

---------------------------
--Component Declaration
---------------------------
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
	signal key_input : std_logic_vector(0 to 127) := (others => '0'); 
	signal en : std_logic := '0'; 
	signal clk : std_logic := '0';
	constant clk_period : time := 100 ns;
	signal reset : std_logic := '0'; 


---------------------------
--Outputs
---------------------------
    signal w_output : round_keys;
    signal done : std_logic; 

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: KeyExpansion 
    PORT MAP (
        key => key_input,
        en => en,
        reset => reset, 
        clk => clk,
        done => done,
        w => w_output);
    
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
        key_input <= x"2b7e151628aed2a6abf7158809cf4f3c";
        wait for 10 * clk_period; 
        en <= '1'; 
        wait for 20 * clk_period;
        reset <= '1';  
        wait; 
    end process;

END testbench;