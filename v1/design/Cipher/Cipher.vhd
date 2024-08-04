----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: Cipher for AES - Behavioral
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

entity Cipher is
    Port ( 
        clk : in std_logic; 
        data_in : in std_logic_vector (127 downto 0); 
        enc_en : in std_logic; 
        reset : in std_logic; 
        w : in round_keys;
        ready : out std_logic; 
        data_out : out std_logic_vector(127 downto 0));
end Cipher;

architecture Behavioral of Cipher is

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
signal state_in_reg : state_matrix := (others => (others => (others => '0'))); 
signal add_round_key_input : state_matrix := (others => (others => (others => '0')));
signal add_round_key_output : state_matrix := (others => (others => (others => '0')));
signal sub_bytes_output : state_matrix := (others => (others => (others => '0'))); 
signal shift_rows_output : state_matrix := (others => (others => (others => '0'))); 
signal mix_columns_output : state_matrix := (others => (others => (others => '0'))); 
signal round : integer range 0 to 10 := 0;
signal temp_state : state_matrix := (others => (others => (others => '0')));
 
---------------------------
--FSM Signal Declarations
---------------------------
signal add_round_key_en : std_logic := '0'; 
signal sub_bytes_en : std_logic := '0'; 
signal shift_rows_en : std_logic := '0';
signal mix_columns_en : std_logic := '0'; 
signal add_round_key_done : std_logic := '0'; 
signal sub_bytes_done : std_logic := '0'; 
signal shift_rows_done : std_logic := '0';
signal mix_columns_done : std_logic := '0'; 
---------------------------
--FSM States
---------------------------
type state_type is (Idle, AddRoundKeyState, SubBytesState, ShiftRowsState, MixColumnsState, ReadyState, LoadState); 
signal CS, NS : state_type := Idle; 

begin 

    add_round_key : AddRoundKey
    port map(
        state_in => add_round_key_input, 
        clk => clk, 
        reset => reset, 
        en => add_round_key_en,
        w => w, 
        round => round,
        done => add_round_key_done, 
        state_out => add_round_key_output);
        
    sub_bytes : SubBytes
    port map(
        state_in => add_round_key_output, 
        en => sub_bytes_en, 
        reset => reset, 
        clk => clk, 
        done => sub_bytes_done,
        state_out => sub_bytes_output); 
        
    shift_rows : ShiftRows
    port map(
        state_in => sub_bytes_output, 
        en => shift_rows_en, 
        reset => reset, 
        clk => clk,
        done => shift_rows_done,
        state_out => shift_rows_output);
    
    mix_columns : MixColumns
    port map(
        state_in => shift_rows_output, 
        en => mix_columns_en, 
        reset => reset, 
        clk => clk,
        done => mix_columns_done,
        state_out => mix_columns_output);
        
    state_update: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                CS <= Idle;
            else 
                CS <= NS;   
            end if;  
        end if; 
    end process;    
    
    process(clk)
    begin 
        if rising_edge(clk) then
            if CS = LoadState then
                state_in_reg(0,0) <= data_in(127 downto 120); 
                state_in_reg(1,0) <= data_in(119 downto 112);
                state_in_reg(2,0) <= data_in(111 downto 104); 
                state_in_reg(3,0) <= data_in(103 downto 96); 
                state_in_reg(0,1) <= data_in(95 downto 88); 
                state_in_reg(1,1) <= data_in(87 downto 80); 
                state_in_reg(2,1) <= data_in(79 downto 72); 
                state_in_reg(3,1) <= data_in(71 downto 64); 
                state_in_reg(0,2) <= data_in(63 downto 56); 
                state_in_reg(1,2) <= data_in(55 downto 48);
                state_in_reg(2,2) <= data_in(47 downto 40); 
                state_in_reg(3,2) <= data_in(39 downto 32); 
                state_in_reg(0,3) <= data_in(31 downto 24); 
                state_in_reg(1,3) <= data_in(23 downto 16); 
                state_in_reg(2,3) <= data_in(15 downto 8); 
                state_in_reg(3,3) <= data_in(7 downto 0); 
            end if;  
        end if; 
    end process; 
    
    
    ns_logic : process(CS, add_round_key_done, sub_bytes_done, shift_rows_done, mix_columns_done, round, enc_en)
    begin
        NS <= CS;
        case CS is
            when Idle =>  
                if enc_en = '1' then 
                    NS <= LoadState; 
                end if; 
            when LoadState => 
                NS <= AddRoundKeyState; 
            when AddRoundKeyState => 
                if add_round_key_done = '1' then 
                    if round = 10 then
                        NS <= ReadyState; 
                    else
                        NS <= SubBytesState;
                    end if;   
                end if; 
            when SubBytesState => 
                if sub_bytes_done = '1' then
                    NS <= ShiftRowsState;  
                end if; 
            when ShiftRowsState => 
                if shift_rows_done = '1' then
                    if round = 10 then
                        NS <= AddRoundKeyState;
                    else   
                        NS <= MixColumnsState; 
                    end if; 
                end if; 
            when MixColumnsState => 
                if mix_columns_done = '1' then 
                    NS <= AddRoundKeyState; 
                end if; 
            when ReadyState => 
                if enc_en = '0' then
                    NS <= Idle;  
                end if;
        end case; 
    end process;
    
    add_round_key_input_logic : process(clk)
    begin
        if rising_edge(clk) then
             case NS is
                when AddRoundKeyState => 
                    if round = 10 then
                        add_round_key_input <= shift_rows_output;
                    elsif round = 0 then 
                        add_round_key_input <= state_in_reg; 
                    else add_round_key_input <= mix_columns_output; 
                    end if; 
                when others => null;
            end case; 
        end if; 
    end process;   
    
    
    output_logic : process(CS)
    begin
        add_round_key_en <= '0'; 
        sub_bytes_en <= '0';
        shift_rows_en <= '0';
        mix_columns_en <= '0'; 
        ready <= '0'; 
        case CS is
            when AddRoundKeyState => 
                add_round_key_en <= '1';
            when SubBytesState => 
                sub_bytes_en <= '1'; 
            when ShiftRowsState => 
                shift_rows_en <= '1'; 
            when MixColumnsState => 
                mix_columns_en <= '1';
            when ReadyState => 
                ready <= '1';
            when Others => null; 
        end case; 
    end process; 
    
    round_counter: process(clk, reset)
    begin
        if reset = '1' then 
            round <= 0; 
        elsif rising_edge(clk) then
            if CS = AddRoundKeyState and add_round_key_done = '1' then
                if round < 10 then
                    round <= round + 1;
                end if;
            elsif CS = ReadyState then 
                round <= 0; 
            end if;
        end if;
    end process;
        
        
data_out(127 downto 120) <= add_round_key_output(0, 0); 
data_out(119 downto 112) <= add_round_key_output(1, 0); 
data_out(111 downto 104) <= add_round_key_output(2, 0);
data_out(103 downto 96) <= add_round_key_output(3, 0);
data_out(95 downto 88) <= add_round_key_output(0, 1);
data_out(87 downto 80) <= add_round_key_output(1, 1);
data_out(79 downto 72) <= add_round_key_output(2, 1);
data_out(71 downto 64) <= add_round_key_output(3, 1);
data_out(63 downto 56) <= add_round_key_output(0, 2);
data_out(55 downto 48) <= add_round_key_output(1, 2);
data_out(47 downto 40) <= add_round_key_output(2, 2);
data_out(39 downto 32) <= add_round_key_output(3, 2);
data_out(31 downto 24) <= add_round_key_output(0, 3);
data_out(23 downto 16) <= add_round_key_output(1, 3);
data_out(15 downto 8) <= add_round_key_output(2, 3);
data_out(7 downto 0) <= add_round_key_output(3, 3);

end Behavioral;
