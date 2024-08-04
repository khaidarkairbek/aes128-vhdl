----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvSubBytes for AES - Testbench
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

ENTITY InvSubBytes_tb IS
END InvSubBytes_tb;

ARCHITECTURE testbench OF InvSubBytes_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT InvSubBytes
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
    uut: InvSubBytes 
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
            (x"e9", x"cb", x"3d", x"af"), 
            (x"09", x"31", x"32", x"2e"), 
            (x"89", x"07", x"7d", x"2c"), 
            (x"72", x"5f", x"94", x"b5")
        );
        wait for 10 * clk_period;
        en <= '1'; 
        -------------------------------
        ---    Expected state out   ---
        ---    eb - 59 - 8b - 1b    ---
        ---    40 - 2e - a1 - c3    ---
        ---    f2 - 38 - 13 - 42    ---
        ---    1e - 84 - e7 - d2    ---
        -------------------------------
        wait for 5 * clk_period; 
        reset <= '1'; 
        wait;
    end process;

END testbench;