library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.opcodes.all; -- Import opcode definitions


-- This entity selects the immediate value or register data based on the opcode
entity mux_alu_src_b is
    port(
        rd2: in std_logic_vector(31 downto 0); -- Data from register rd2
        imm: in std_logic_vector(31 downto 0); -- Immediate value
        opcode: in std_logic_vector(6 downto 0); -- Opcode
        src_b: out std_logic_vector(31 downto 0) -- mux output
    );
end entity mux_alu_src_b;

architecture behavioral of mux_alu_src_b is
begin

    process(opcode)
    begin
        case opcode is
            when OPCODE_OP_IMM => -- I-type instructions (e.g., addi, lw)
                src_b <= imm; -- Use immediate value for I-type instructions

            when OPCODE_LOAD => -- Load instructions (e.g., lw, lbu)
                src_b <= imm; -- Use immediate value for load instructions

            when OPCODE_STORE => -- Store instructions (e.g., sw, sb)
                src_b <= rd2; -- Use data from register rd2 for store instructions

            when OPCODE_BRANCH => -- Branch instructions (e.g., beq, bne)
                src_b <= rd2; -- Use data from register rd2 for branch instructions

            when OPCODE_LUI => -- Load Upper Immediate
                src_b <= imm; -- Use immediate value for LUI

            when OPCODE_AUIPC => -- Add Upper Immediate to PC
                src_b <= imm; -- Use immediate value for AUIPC

            when OPCODE_JAL => -- Jump and Link
                src_b <= imm; -- Use immediate value for JAL

            when others =>
                src_b <= (others => '0'); -- Default case, set to zero
        end case;
    end process;

end architecture behavioral;