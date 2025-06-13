library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package alu_op is
    -- ALU operation codes
    constant ALU_ADD: std_logic_vector(3 downto 0) := "0000"; -- ADD
    constant ALU_SUB: std_logic_vector(3 downto 0) := "0001"; -- SUB
    constant ALU_AND: std_logic_vector(3 downto 0) := "0010"; -- AND
    constant ALU_OR: std_logic_vector(3 downto 0) := "0011"; -- OR
    constant ALU_XOR: std_logic_vector(3 downto 0) := "0100"; -- XOR
    constant ALU_SLL: std_logic_vector(3 downto 0) := "0101"; -- SLL
    constant ALU_SRL: std_logic_vector(3 downto 0) := "0110"; -- SRL
    constant ALU_SRA: std_logic_vector(3 downto 0) := "0111"; -- SRA
    constant ALU_SLT: std_logic_vector(3 downto 0) := "1000"; -- SLT
    constant ALU_SLTU: std_logic_vector(3 downto 0) := "1001"; -- SLTU
    constant ALU_PASS: std_logic_vector(3 downto 0) := "1010"; -- PASS (no operation)
    constant ALU_NOP: std_logic_vector(3 downto 0) := "1110"; -- NOP (no operation)
    constant ALU_INV: std_logic_vector(3 downto 0) := "1111"; -- undefined operation
end package alu_op;

