library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.opcodes.all; -- Import opcode definitions


-- This mux selects between the PC value or register data based on the opcode
entity mux_alu_src_a is
    port(
        rd1: in std_logic_vector(31 downto 0); -- Data from register rs1
        pc: in std_logic_vector(31 downto 0); -- PC
        opcode: in std_logic_vector(6 downto 0); -- Opcode
        src_a: out std_logic_vector(31 downto 0) -- mux output
    );
end entity mux_alu_src_a;

architecture behavioral of mux_alu_src_a is
begin

    process(opcode)
    begin
        case opcode is
            when OPCODE_OP_IMM => -- I-type instructions (e.g., addi, lw)
                src_a <= rd1;

            when OPCODE_LOAD => -- Load instructions (e.g., lw, lbu)
                src_a <= rd1;

            when OPCODE_STORE => -- Store instructions (e.g., sw, sb)
                src_a <= rd1;

            when OPCODE_BRANCH => -- Branch instructions (e.g., beq, bne)
                src_a <= rd1;

            when OPCODE_LUI => -- Load Upper Immediate
                src_a <= rd1;

            when OPCODE_AUIPC => -- Add Upper Immediate to PC
                src_a <= pc;

            when OPCODE_JAL => -- Jump and Link
                src_a <= rd1;
            when others =>
                src_a <= (others => '0'); -- Default case, set to zero
        end case;
    end process;

end architecture behavioral;