----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvShiftRows for AES - Testbench
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

ENTITY InvShiftRows_tb IS
END InvShiftRows_tb;

ARCHITECTURE testbench OF InvShiftRows_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT InvShiftRows
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
    uut: InvShiftRows 
    PORT MAP (
        state_in => state_in,
        en => en,
        clk => clk,
        reset => reset, 
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
            (x"e9", x"cb", x"3d", x"af"), 
            (x"31", x"32", x"2e", x"09"), 
            (x"7d", x"2c", x"89", x"07"), 
            (x"b5", x"72", x"5f", x"94")
        );
        wait for 20 * clk_period;
        en <= '1'; 
        -------------------------------
        ---    Expected state out   ---
        ---    e9 - cb - 3d - af    ---
        ---    09 - 31 - 32 - 2e    ---
        ---    89 - 07 - 7d - 2c    ---
        ---    72 - 5f - 94 - b5    ---
        -------------------------------
        wait for 5 * clk_period; 
        reset <= '1'; 
        wait; 
    end process;

END testbench;
