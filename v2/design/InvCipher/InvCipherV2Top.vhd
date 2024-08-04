----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek
-- Module Name: InvCipherV2Top for AES - Behavioral
-- Project Name: AES Algorithm Implementation
-- Target Device: Basys 3
-- Description: Top level for testing InvCipherV2 using UART interface
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work; 
use work.state_pkg.all; 

entity InvCipherV2Top is 
port (	clk : in std_logic;
        reset : in std_logic; 
		sci_rx_ext : in std_logic;
		sci_tx_ext : out std_logic;  
		reset_led : out std_logic
);
end entity;

architecture Behavioral of InvCipherV2Top is

-- InvCipher signals
signal key : std_logic_vector(127 downto 0) := (others => '0');
signal key_ready, key_en : std_logic := '0';
signal invcipher_data_in : std_logic_vector(127 downto 0) := (others => '0');
signal invcipher_data_out : std_logic_vector(127 downto 0) := (others => '0');
signal invcipher_en, invcipher_ready : std_logic := '0';
signal invcipher_words_in, key_words_out : round_keys := (others => (others => '0')); 

--SCI signals
signal sci_rx_data_out, sci_tx_data_in : std_logic_vector(7 downto 0) := (others => '0');
signal sci_tx_data_buf : std_logic_vector(127 downto 0) := (others => '0'); 
signal sci_rx_ready : std_logic := '0';
signal transmit_en, sci_tx_ready : std_logic := '0';
signal sci_tx_new_byte : std_logic := '0'; 
constant SCI_RX_BAUD_PERIOD : integer := 10416;    -- for synthesis
constant SCI_TX_BAUD_PERIOD : integer := 10416;    -- for synthesis
--constant SCI_RX_BAUD_PERIOD : integer := 10;     -- for simulation
--constant SCI_TX_BAUD_PERIOD : integer := 10;     -- for simulation

--
signal input_buffer : std_logic_vector(127 downto 0) := (others => '0');

type receive_state_t is (RECEIVE_KEY, UPDATE_KEY, RECEIVE_DATA, UPDATE_INVCIPHER_DATA);
signal receive_cs, receive_ns : receive_state_t := RECEIVE_KEY;
signal rx_byte_count : natural range 0 to 15 := 0;
signal rx_byte_tc, key_reg_update_en : std_logic := '0'; 

type transmit_state_t is (IDLE, TRANSMIT);
signal transmit_cs, transmit_ns : transmit_state_t := IDLE;
signal tx_byte_count : natural range 0 to 15 := 0;
signal tx_byte_tc : std_logic := '0'; 
signal sci_tx_out : std_logic := '1'; 



---------------------------
--InvCipher
---------------------------
component InvCipherV2 is 
    Port ( 
        clk : in std_logic; 
        data_in : in std_logic_vector (127 downto 0);
        dec_en : in std_logic; 
        reset : in std_logic; 
        w : in round_keys;
        ready : out std_logic; 
        data_out : out std_logic_vector (127 downto 0));
end component;

---------------------------
--Key generator
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

-------------------
-- SCI Receiver 
-------------------
component Sci_Rx is 
    generic(
        BAUD_PERIOD : integer);
    port(
        receive_en : in std_logic;
        reset : in std_logic; 
        clk : in std_logic; 
        rx : in std_logic; 
        sci_ready : out std_logic; 
        sci_output : out std_logic_vector(7 downto 0));
end component;

-------------------
-- SCI Transmitter
-------------------
component Sci_Tx is 
    generic (
        BAUD_PERIOD : integer);
    port ( 
        data_in : in std_logic_vector(7 downto 0);
        transmit_en : in std_logic; 
        reset : in std_logic; 
        clk : in std_logic;
        tx: out std_logic;
        new_symbol: out std_logic);
end component;



begin

key_generator : KeyExpansion 
    port map (
        key => key, 
        en => key_en, 
        reset => reset, 
        clk => clk, 
        done => key_ready, 
        w => key_words_out
    ); 

invcipher_comp : InvCipherV2
	port map (
		clk => clk,
		data_in => invcipher_data_in, 
		dec_en => invcipher_en, 
		reset => reset, 
		w => invcipher_words_in, 
		ready => invcipher_ready, 
		data_out => invcipher_data_out
	);

sci_tx_comp : Sci_Tx
    generic map (
        BAUD_PERIOD => SCI_TX_BAUD_PERIOD)
	port map (	
		clk => clk,
		data_in => sci_tx_data_in, 
		transmit_en => transmit_en, 
		reset => reset, 
		tx => sci_tx_out,
		new_symbol => sci_tx_new_byte
	);
	
	
sci_rx_comp : Sci_Rx
	generic map ( 
	   BAUD_PERIOD => SCI_TX_BAUD_PERIOD)
	port map ( 
		clk => clk,
		receive_en => '1', 
		reset => reset, 
		rx => sci_rx_ext, 
		sci_ready => sci_rx_ready, 
		sci_output => sci_rx_data_out 
	);

state_update: process(clk, reset)
begin
    if reset = '1' then 
        receive_cs <= RECEIVE_KEY; 
        transmit_cs <= IDLE;  
    elsif rising_edge(clk) then
        receive_cs <= receive_ns; 
        transmit_cs <= transmit_ns;  
    end if; 
end process;

transmit_ns_logic : process (transmit_cs, invcipher_ready, tx_byte_tc)
begin
    transmit_ns <= transmit_cs; 
    case transmit_cs is
        when IDLE =>
            if invcipher_ready = '1' then
                transmit_ns <= TRANSMIT; 
            end if;
        when TRANSMIT => 
            if tx_byte_tc = '1' then
                transmit_ns <= IDLE;  
            end if; 
    end case;
end process;

transmit_output_logic : process(transmit_cs, sci_tx_new_byte, tx_byte_count)
begin
    transmit_en <= '0'; 
    case transmit_cs is 
        when TRANSMIT =>  
            transmit_en <= '1';
        when others => null;  
    end case; 
end process;

tx_byte_counter: process(clk, tx_byte_count, reset)
begin
    if reset = '1' then 
        tx_byte_count <= 0; 
    elsif rising_edge(clk) then 
        tx_byte_tc <= '0'; 
        if sci_tx_new_byte = '1' then 
            if tx_byte_count = 15 then 
                tx_byte_tc <= '1'; 
                tx_byte_count <= 0;
            else
                tx_byte_count <= tx_byte_count + 1; 
            end if;     
        end if;
    end if; 
end process; 

tx_data_in_reg : process(clk)
begin
    if rising_edge(clk) then
         if transmit_en = '0' and invcipher_ready = '1' then 
            sci_tx_data_buf <= invcipher_data_out;  
         end if; 
    end if; 
end process; 
 
sci_tx_data_in <= sci_tx_data_buf(127 - 8 * tx_byte_count downto 120 - 8 * tx_byte_count);
key <= input_buffer; 
invcipher_data_in <= input_buffer;

receiver_ns_logic: process(receive_cs, rx_byte_tc, key_ready)
begin
    receive_ns <= receive_cs; 
    case receive_cs is 
        when RECEIVE_KEY => 
            if rx_byte_tc = '1' then
                receive_ns <= UPDATE_KEY; 
            end if; 
        when UPDATE_KEY => 
            if rx_byte_tc = '0' then 
                receive_ns <= RECEIVE_DATA;
            end if; 
        when RECEIVE_DATA => 
            if rx_byte_tc = '1' then
                receive_ns <= UPDATE_INVCIPHER_DATA; 
            end if;
        when UPDATE_INVCIPHER_DATA => 
            if rx_byte_tc = '0' then 
                receive_ns <= RECEIVE_DATA;
            end if;
    end case; 
end process; 

input_buffer_register : process(clk)
begin
    if rising_edge(clk) then
        if sci_rx_ready = '1' then 
            input_buffer <= input_buffer(119 downto 0) & sci_rx_data_out;
        end if; 
    end if;   
end process;

rx_byte_counter: process(clk, reset)
begin
    if reset = '1' then
        rx_byte_count <= 0; 
    elsif rising_edge(clk) then 
        rx_byte_tc <= '0';
        if sci_rx_ready = '1' then 
            if rx_byte_count = 15 then 
                rx_byte_tc <= '1';
                rx_byte_count <= 0; 
            else 
                rx_byte_count <= rx_byte_count + 1;
            end if;      
        end if;
    end if;
end process;

receiver_output_logic : process(receive_cs)
begin
    key_en <= '0';
    invcipher_en <= '0'; 
    case receive_cs is  
        when UPDATE_KEY => 
            key_en <= '1'; 
        when UPDATE_INVCIPHER_DATA => 
            invcipher_en <= '1'; 
        when others => null;
    end case; 
end process; 

key_cipher_input_reg : process(clk)
begin
    if rising_edge(clk) then 
        if key_ready = '1' then 
            invcipher_words_in <= key_words_out; 
        end if;
    end if; 
end process;  

reset_led <= reset; 
sci_tx_ext <= sci_tx_out; 
end;