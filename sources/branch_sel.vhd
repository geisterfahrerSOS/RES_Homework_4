library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package branch_sel is
    -- ALU operation codes
    constant BEQ: std_logic_vector(2 downto 0) := "000"; -- Branch if Equal
    constant BNE: std_logic_vector(2 downto 0) := "001"; -- Branch if Not Equal
    constant BLT: std_logic_vector(2 downto 0) := "100"; -- Branch if Less Than
    constant BGE: std_logic_vector(2 downto 0) := "101"; -- Branch if Greater Than or Equal
    constant BGEU: std_logic_vector(2 downto 0) := "111"; -- Branch if Not Equal to Zero
end package branch_sel;