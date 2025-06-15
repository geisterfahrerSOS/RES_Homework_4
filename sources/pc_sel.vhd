library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package pc_sel is
    constant PC_PLUS_4       : std_logic_vector(1 downto 0) := "00"; -- PC + 4
    constant PC_JABS     : std_logic_vector(1 downto 0) := "01"; -- Jump Absolute
    constant PC_JALR        : std_logic_vector(1 downto 0) := "10"; -- Register Indirect (jalr) RIND
    constant PC_BR         : std_logic_vector(1 downto 0) := "11"; -- Branch (jal / jalr)
end package pc_sel;