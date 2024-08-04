----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvCipherV2Top for AES - Testbench
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

ENTITY InvCipherV2Top_tb IS
END InvCipherV2Top_tb;

ARCHITECTURE testbench OF InvCipherV2Top_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT InvCipherV2Top
    PORT(
        clk : in std_logic;
        reset : in std_logic; 
		sci_rx_ext : in std_logic;
		sci_tx_ext : out std_logic;  
		reset_led : out std_logic);
    end component;
---------------------------
--Inputs
---------------------------
	signal sci_rx_ext : std_logic := '1';
    constant clk_period : time := 100 ns;
    signal clk : std_logic := '0'; 
    signal data : std_logic_vector(127 downto 0) := x"3925841d02dc09fbdc118597196a0b32"; 
    signal key : std_logic_vector(127 downto 0) := x"2b7e151628aed2a6abf7158809cf4f3c";
    signal sci_byte : std_logic_vector(9 downto 0) := (others => '0'); 
    signal reset : std_logic := '0'; 
    
---------------------------
--Outputs
---------------------------
    signal sci_tx_ext : std_logic;

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: InvCipherV2Top 
    PORT MAP (
        clk => clk,
        sci_rx_ext => sci_rx_ext,
        reset => reset, 
        sci_tx_ext => sci_tx_ext);
        
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
        wait for 100 * clk_period;
        
        for i in 0 to 15 loop
             sci_byte <= "1" & key(127 - 8 * i downto 120 - 8 * i) & "0"; 
             for j in 0 to 9 loop
                sci_rx_ext <= sci_byte(j);
                wait for 10 * clk_period;  
             end loop; 
        end loop; 
        
        sci_rx_ext <= '1'; 
        wait for 100 * clk_period; 
        
        for i in 0 to 15 loop
             sci_byte <= "1" & data(127 - 8 * i downto 120 - 8 * i) & "0"; 
             for j in 0 to 9 loop
                sci_rx_ext <= sci_byte(j);
                wait for 10 * clk_period;  
             end loop; 
        end loop;
        
        sci_rx_ext <= '1'; 
        wait for 10000 * clk_period; 
        
        reset <= '1'; 
        wait for 10 * clk_period; 
        
        reset <= '0'; 
        wait for 10 * clk_period; 
        
        for i in 0 to 15 loop
             sci_byte <= "1" & key(127 - 8 * i downto 120 - 8 * i) & "0"; 
             for j in 0 to 9 loop
                sci_rx_ext <= sci_byte(j);
                wait for 10 * clk_period;  
             end loop; 
        end loop; 
        
        sci_rx_ext <= '1'; 
        wait for 100 * clk_period; 
        
        for i in 0 to 15 loop
             sci_byte <= "1" & data(127 - 8 * i downto 120 - 8 * i) & "0"; 
             for j in 0 to 9 loop
                sci_rx_ext <= sci_byte(j);
                wait for 10 * clk_period;  
             end loop; 
        end loop;
        
        sci_rx_ext <= '1'; 
        wait for 100 * clk_period; 
        
        for i in 0 to 15 loop
             sci_byte <= "1" & data(127 - 8 * i downto 120 - 8 * i) & "0"; 
             for j in 0 to 9 loop
                sci_rx_ext <= sci_byte(j);
                wait for 10 * clk_period;  
             end loop; 
        end loop;
        
        wait; 
    end process;
    
end testbench;