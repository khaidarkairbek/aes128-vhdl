library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package state_pkg is
        type state_matrix is array(0 to 3, 0 to 3) of std_logic_vector(7 downto 0);
        subtype round_key is std_logic_vector(31 downto 0); 
        type round_keys is array(0 to 43) of round_key; 
end package;
