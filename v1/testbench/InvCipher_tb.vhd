----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvCipher for AES - Testbench
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

ENTITY InvCipher_tb IS
END InvCipher_tb;

ARCHITECTURE testbench OF InvCipher_tb IS 

---------------------------
--Component Declaration
---------------------------
    COMPONENT InvCipher
    PORT(
        clk : in std_logic; 
        data_in : in std_logic_vector(127 downto 0); 
        dec_en : in std_logic; 
        w : in round_keys;
        reset : in std_logic;
        ready : out std_logic; 
        data_out : out std_logic_vector(127 downto 0));
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
	signal data_in : std_logic_vector(127 downto 0) := (others => '0'); 
    signal reset : std_logic := '0';
    signal w : round_keys := (others => (others => '0'));
    signal key : std_logic_vector(127 downto 0) := (others => '0');  
    signal key_en : std_logic := '0'; 
    signal key_done : std_logic := '0'; 
    signal dec_en : std_logic := '0'; 
    signal clk : std_logic := '0'; 
    signal ready : std_logic := '0'; 
    constant clk_period : time := 100 ns; -- 10MHz
---------------------------
--Outputs
---------------------------
    signal data_out : std_logic_vector(127 downto 0); 

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: InvCipher 
    PORT MAP (
        data_in => data_in,
        dec_en => dec_en, 
        clk => clk, 
        w => w,
        reset => reset,
        ready => ready, 
        data_out => data_out);
    
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
        data_in <= x"3925841d02dc09fbdc118597196a0b32";
        wait for 20 * clk_period;
        dec_en <= '1';
        --------------------------------------
        ---    Expected data out           ---
        ---3243f6a8885a308d313198a2e0370734---
        --------------------------------------
        wait; 
    end process;

END testbench;
