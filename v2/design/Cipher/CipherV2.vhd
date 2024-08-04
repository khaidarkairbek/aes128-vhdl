----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: CipherV2 for AES - Behavioral
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

entity CipherV2 is
    Port ( 
        clk : in std_logic; 
        data_in : in std_logic_vector (127 downto 0); 
        enc_en : in std_logic; 
        reset : in std_logic; 
        w : in round_keys;
        ready : out std_logic; 
        data_out : out std_logic_vector(127 downto 0));
end CipherV2;

architecture Behavioral of CipherV2 is

---------------------------
--AddRoundKey
---------------------------
component AddRoundKey is 
    Port ( 
        state_in : in state_matrix;
        en : in std_logic;  
        reset : in std_logic; 
        clk : in std_logic; 
        w : in round_keys; 
        round : in natural range 0 to 10;
        done : out std_logic;  
        state_out : out state_matrix);
end component;

---------------------------
--SubBytes
---------------------------
component SubBytes is 
    Port ( 
        state_in : in state_matrix;
        en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic;
        done : out std_logic; 
        state_out : out state_matrix);
end component;

---------------------------
--ShiftRows
---------------------------
component ShiftRows is 
    Port ( 
        state_in : in state_matrix;
        en : in std_logic;
        reset : in std_logic; 
        clk : in std_logic; 
        done : out std_logic; 
        state_out : out state_matrix);
end component;

---------------------------
--MixColumns
---------------------------
component MixColumns is 
    Port ( 
        state_in : in state_matrix;
        en : in std_logic;
        reset : in std_logic; 
        clk : in std_logic;
        done : out std_logic;
        state_out : out state_matrix);
end component;


---------------------------
--Signal Declarations
---------------------------
type state_matrix_array_t  is array(0 to 9) of state_matrix; 
signal add_round_key_input : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal add_round_key_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal add_round_key_output_last : state_matrix := (others => (others => (others => '0')));
signal sub_bytes_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal shift_rows_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal mix_columns_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
 
---------------------------
--FSM Signal Declarations
---------------------------
type en_array_t is array(0 to 9) of std_logic; 
signal add_round_key_en : en_array_t := (others => '0');  
signal add_round_key_done : en_array_t := (others => '0'); 
signal sub_bytes_done : en_array_t := (others => '0'); 
signal shift_rows_done : en_array_t := (others => '0'); 
signal mix_columns_done : en_array_t := (others => '0');  

begin 

    add_round_key_input(0)(0,0) <= data_in(127 downto 120); 
    add_round_key_input(0)(1,0) <= data_in(119 downto 112);
    add_round_key_input(0)(2,0) <= data_in(111 downto 104); 
    add_round_key_input(0)(3,0) <= data_in(103 downto 96); 
    add_round_key_input(0)(0,1) <= data_in(95 downto 88); 
    add_round_key_input(0)(1,1) <= data_in(87 downto 80); 
    add_round_key_input(0)(2,1) <= data_in(79 downto 72); 
    add_round_key_input(0)(3,1) <= data_in(71 downto 64); 
    add_round_key_input(0)(0,2) <= data_in(63 downto 56); 
    add_round_key_input(0)(1,2) <= data_in(55 downto 48);
    add_round_key_input(0)(2,2) <= data_in(47 downto 40); 
    add_round_key_input(0)(3,2) <= data_in(39 downto 32); 
    add_round_key_input(0)(0,3) <= data_in(31 downto 24); 
    add_round_key_input(0)(1,3) <= data_in(23 downto 16); 
    add_round_key_input(0)(2,3) <= data_in(15 downto 8); 
    add_round_key_input(0)(3,3) <= data_in(7 downto 0); 

    add_round_key_input_logic: for i in 1 to 9 generate
        add_round_key_input(i) <= mix_columns_output(i - 1); 
    end generate add_round_key_input_logic; 
    
    add_round_key_en_logic: for i in 0 to 9 generate
        add_round_key_en(i) <= enc_en when i = 0 else mix_columns_done(i-1); 
    end generate; 
    
    
    rounds : for i in 0 to 8 generate
        add_round_key_r : AddRoundKey
        port map(
            state_in => add_round_key_input(i), 
            clk => clk, 
            reset => reset, 
            en => add_round_key_en(i),
            w => w, 
            round => i,
            done => add_round_key_done(i), 
            state_out => add_round_key_output(i));
            
        sub_bytes_r : SubBytes
        port map(
            state_in => add_round_key_output(i), 
            en => add_round_key_done(i), 
            reset => reset, 
            clk => clk, 
            done => sub_bytes_done(i),
            state_out => sub_bytes_output(i)); 
            
        shift_rows_r : ShiftRows
        port map(
            state_in => sub_bytes_output(i), 
            en => sub_bytes_done(i), 
            reset => reset, 
            clk => clk,
            done => shift_rows_done(i),
            state_out => shift_rows_output(i));
        
        mix_columns_r : MixColumns
        port map(
            state_in => shift_rows_output(i), 
            en => shift_rows_done(i), 
            reset => reset, 
            clk => clk,
            done => mix_columns_done(i),
            state_out => mix_columns_output(i));
    end generate rounds;  
        
     
    add_round_key_9 : AddRoundKey
    port map (
        state_in => mix_columns_output(8), 
        clk => clk, 
        reset => reset, 
        en => mix_columns_done(8),
        w => w, 
        round => 9,
        done => add_round_key_done(9), 
        state_out => add_round_key_output(9)); 
        
    sub_bytes_9 : SubBytes
    port map(
        state_in => add_round_key_output(9), 
        en => add_round_key_done(9), 
        reset => reset, 
        clk => clk, 
        done => sub_bytes_done(9),
        state_out => sub_bytes_output(9)); 
        
    shift_rows_9 : ShiftRows
    port map(
        state_in => sub_bytes_output(9), 
        en => sub_bytes_done(9), 
        reset => reset, 
        clk => clk,
        done => shift_rows_done(9),
        state_out => shift_rows_output(9));   
   
    add_round_key_10 : AddRoundKey
    port map (
        state_in => shift_rows_output(9), 
        clk => clk, 
        reset => reset, 
        en => shift_rows_done(9),
        w => w, 
        round => 10,
        done => ready, 
        state_out => add_round_key_output_last);   
        
        
    data_out(127 downto 120) <= add_round_key_output_last(0, 0); 
    data_out(119 downto 112) <= add_round_key_output_last(1, 0); 
    data_out(111 downto 104) <= add_round_key_output_last(2, 0);
    data_out(103 downto 96) <= add_round_key_output_last(3, 0);
    data_out(95 downto 88) <= add_round_key_output_last(0, 1);
    data_out(87 downto 80) <= add_round_key_output_last(1, 1);
    data_out(79 downto 72) <= add_round_key_output_last(2, 1);
    data_out(71 downto 64) <= add_round_key_output_last(3, 1);
    data_out(63 downto 56) <= add_round_key_output_last(0, 2);
    data_out(55 downto 48) <= add_round_key_output_last(1, 2);
    data_out(47 downto 40) <= add_round_key_output_last(2, 2);
    data_out(39 downto 32) <= add_round_key_output_last(3, 2);
    data_out(31 downto 24) <= add_round_key_output_last(0, 3);
    data_out(23 downto 16) <= add_round_key_output_last(1, 3);
    data_out(15 downto 8) <= add_round_key_output_last(2, 3);
    data_out(7 downto 0) <= add_round_key_output_last(3, 3);

end Behavioral;
