library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package byte_enable is
    -- ALU operation codes
    constant ALU_ADD: std_logic_vector(3 downto 0) := "0000"; -- ADD
end package byte_enable;
