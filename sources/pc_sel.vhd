library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package pc_sel is
    constant PC_PLUS_4       : std_logic_vector(2 downto 0) := "000"; -- PC + 4
    constant PC_JABS     : std_logic_vector(2 downto 0) := "001"; -- Jump Absolute
    constant PC_JALR        : std_logic_vector(2 downto 0) := "010"; -- Jump and Link Register (jalr)
    constant PC_BR         : std_logic_vector(2 downto 0) := "011"; -- Branch
    constant PC_JAL        : std_logic_vector(2 downto 0) := "100"; -- Jump and Link (jal)
end package pc_sel;