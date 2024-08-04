----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvCipherV2 for AES - Behavioral
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

entity InvCipherV2 is
    Port ( 
        clk : in std_logic; 
        data_in : in std_logic_vector(127 downto 0); 
        dec_en : in std_logic; 
        w : in round_keys;
        reset : in std_logic;
        ready : out std_logic; 
        data_out : out std_logic_vector(127 downto 0));
end InvCipherV2;

architecture Behavioral of InvCipherV2 is

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
--InvSubBytes
---------------------------
component InvSubBytes is 
    Port ( 
        state_in : in state_matrix; 
        reset : in std_logic; 
        en : in std_logic; 
        clk : in std_logic; 
        done : out std_logic; 
        state_out : out state_matrix);
end component;

---------------------------
--InvShiftRows
---------------------------
component InvShiftRows is 
    Port ( 
        state_in : in state_matrix; 
        en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic;
        done : out std_logic;
        state_out : out state_matrix);
end component;

---------------------------
--InvMixColumns
---------------------------
component InvMixColumns is 
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
signal state_in : state_matrix := (others => (others => (others => '0')));
type state_matrix_array_t  is array(9 downto 0) of state_matrix;  
signal add_round_key_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal inv_sub_bytes_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal inv_shift_rows_input : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal inv_shift_rows_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
signal inv_mix_columns_output : state_matrix_array_t := (others => (others => (others => (others => '0'))));
 
---------------------------
--FSM Signal Declarations
---------------------------
type en_array_t is array(9 downto 0) of std_logic;
signal add_round_key_en : en_array_t := (others => '0'); 
signal inv_sub_bytes_en : en_array_t := (others => '0'); 
signal inv_shift_rows_en : en_array_t := (others => '0'); 
signal inv_mix_columns_en : en_array_t := (others => '0'); 
signal add_round_key_done : en_array_t := (others => '0');

begin


    state_in(0,0) <= data_in(127 downto 120); 
    state_in(1,0) <= data_in(119 downto 112);
    state_in(2,0) <= data_in(111 downto 104); 
    state_in(3,0) <= data_in(103 downto 96); 
    state_in(0,1) <= data_in(95 downto 88); 
    state_in(1,1) <= data_in(87 downto 80); 
    state_in(2,1) <= data_in(79 downto 72); 
    state_in(3,1) <= data_in(71 downto 64); 
    state_in(0,2) <= data_in(63 downto 56); 
    state_in(1,2) <= data_in(55 downto 48);
    state_in(2,2) <= data_in(47 downto 40); 
    state_in(3,2) <= data_in(39 downto 32); 
    state_in(0,3) <= data_in(31 downto 24); 
    state_in(1,3) <= data_in(23 downto 16); 
    state_in(2,3) <= data_in(15 downto 8); 
    state_in(3,3) <= data_in(7 downto 0);
    
    add_round_key_10 : AddRoundKey
    port map (
        state_in => state_in, 
        clk => clk, 
        reset => reset, 
        en => dec_en,
        w => w, 
        round => 10,
        done => inv_shift_rows_en(9), 
        state_out => inv_shift_rows_input(9));
    
    invshift_rows_9 : InvShiftRows
    port map(
        state_in => inv_shift_rows_input(9), 
        en => inv_shift_rows_en(9), 
        reset => reset, 
        clk => clk,
        done => inv_sub_bytes_en(9),
        state_out => inv_shift_rows_output(9));
        
    invsub_bytes_9 : InvSubBytes
    port map(
        state_in => inv_shift_rows_output(9), 
        en => inv_sub_bytes_en(9), 
        reset => reset, 
        clk => clk, 
        done => add_round_key_en(9),
        state_out => inv_sub_bytes_output(9));
        
    add_round_key_9 : AddRoundKey
    port map (
        state_in => inv_sub_bytes_output(9), 
        clk => clk, 
        reset => reset, 
        en => add_round_key_en(9),
        w => w, 
        round => 9,
        done => add_round_key_done(9), 
        state_out => add_round_key_output(9));
        

    rounds : for i in 8 downto 0 generate
        invmix_columns_r : InvMixColumns
        port map(
            state_in => add_round_key_output(i+1), 
            en => inv_mix_columns_en(i), 
            reset => reset, 
            clk => clk,
            done => inv_shift_rows_en(i),
            state_out => inv_mix_columns_output(i));
            
        invshift_rows_r : InvShiftRows
        port map(
            state_in => inv_mix_columns_output(i), 
            en => inv_shift_rows_en(i), 
            reset => reset, 
            clk => clk,
            done => inv_sub_bytes_en(i),
            state_out => inv_shift_rows_output(i));
            
        invsub_bytes_r : InvSubBytes
        port map(
            state_in => inv_shift_rows_output(i), 
            en => inv_sub_bytes_en(i), 
            reset => reset, 
            clk => clk, 
            done => add_round_key_en(i),
            state_out => inv_sub_bytes_output(i));
            
        add_round_key_r : AddRoundKey
        port map(
            state_in => inv_sub_bytes_output(i), 
            clk => clk, 
            reset => reset, 
            en => add_round_key_en(i),
            w => w, 
            round => i,
            done => add_round_key_done(i), 
            state_out => add_round_key_output(i));
           
    end generate rounds; 
    
    inv_mix_columns_en_logic: for i in 8 downto 0 generate
        inv_mix_columns_en(i) <= add_round_key_done(i + 1);
    end generate inv_mix_columns_en_logic;  
    
    ready <= add_round_key_done(0); 
        
    data_out(127 downto 120) <= add_round_key_output(0)(0, 0); 
    data_out(119 downto 112) <= add_round_key_output(0)(1, 0); 
    data_out(111 downto 104) <= add_round_key_output(0)(2, 0);
    data_out(103 downto 96) <= add_round_key_output(0)(3, 0);
    data_out(95 downto 88) <= add_round_key_output(0)(0, 1);
    data_out(87 downto 80) <= add_round_key_output(0)(1, 1);
    data_out(79 downto 72) <= add_round_key_output(0)(2, 1);
    data_out(71 downto 64) <= add_round_key_output(0)(3, 1);
    data_out(63 downto 56) <= add_round_key_output(0)(0, 2);
    data_out(55 downto 48) <= add_round_key_output(0)(1, 2);
    data_out(47 downto 40) <= add_round_key_output(0)(2, 2);
    data_out(39 downto 32) <= add_round_key_output(0)(3, 2);
    data_out(31 downto 24) <= add_round_key_output(0)(0, 3);
    data_out(23 downto 16) <= add_round_key_output(0)(1, 3);
    data_out(15 downto 8) <= add_round_key_output(0)(2, 3);
    data_out(7 downto 0) <= add_round_key_output(0)(3, 3);

end Behavioral;