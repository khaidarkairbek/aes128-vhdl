----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: SubBytes for AES - Testbench
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

ENTITY SubBytes_tb IS
END SubBytes_tb;

ARCHITECTURE testbench OF SubBytes_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT SubBytes
    Port ( 
        state_in : in state_matrix; 
        reset : in std_logic; 
        en : in std_logic;
        clk : in std_logic; 
        done : out std_logic; 
        state_out : out state_matrix);
    end component;
    
---------------------------
--Inputs
---------------------------
	signal state_in : state_matrix := (others => (others => (others => '0')));  
	signal clk : std_logic := '0'; 
	signal en : std_logic := '0'; 
	constant clk_period : time := 100 ns; 
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
    uut: SubBytes 
    PORT MAP (
        state_in => state_in,
        clk => clk, 
        reset => reset, 
        en => en,
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
            (x"19", x"a0", x"9a", x"e9"), 
            (x"3d", x"f4", x"c6", x"f8"), 
            (x"e3", x"e2", x"8d", x"48"), 
            (x"be", x"2b", x"2a", x"08")
        );
        wait for 10 * clk_period;
        en <= '1'; 
        -------------------------------
        ---    Expected state out   ---
        ---    d4 - e0 - b8 - 1e    ---
        ---    27 - bf - b4 - 41    ---
        ---    11 - 98 - 5d - 52    ---
        ---    ae - f1 - e5 - 30    ---
        -------------------------------
        wait for 5 * clk_period; 
        reset <= '1'; 
        wait;  
    end process;

END testbench;