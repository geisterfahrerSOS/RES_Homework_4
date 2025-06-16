library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package wb_sel is
    constant WB_ALU : std_logic_vector(1 downto 0) := "00"; -- ALU result
    constant WB_PC_PLUS_4 : std_logic_vector(1 downto 0) := "01"; -- PC + 4
    constant WB_IMM : std_logic_vector(1 downto 0) := "10"; -- When an immediate value passed by the ALU
    constant WB_MEM : std_logic_vector(1 downto 0) := "11"; -- Memory data
    
end package wb_sel;