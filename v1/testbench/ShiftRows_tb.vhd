----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: ShiftRows for AES - Testbench
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

ENTITY ShiftRows_tb IS
END ShiftRows_tb;

ARCHITECTURE testbench OF ShiftRows_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT ShiftRows
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
    uut: ShiftRows 
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
            (x"d4", x"e0", x"b8", x"1e"), 
            (x"27", x"bf", x"b4", x"41"), 
            (x"11", x"98", x"5d", x"52"), 
            (x"ae", x"f1", x"e5", x"30")
        );
        wait for 10 * clk_period;
        en <= '1'; 
        -------------------------------
        ---    Expected state out   ---
        ---    d4 - e0 - b8 - 1e    ---
        ---    bf - b4 - 41 - 27    ---
        ---    5d - 52 - 11 - 98    ---
        ---    30 - ae - f1 - e5    ---
        -------------------------------
        wait for 5 * clk_period; 
        reset <= '1'; 
        wait; 
    end process;

END testbench;