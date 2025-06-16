library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.opcodes.all; -- Import opcode definitions

entity imm_generator is
    port (
        instr : in std_logic_vector(31 downto 0); -- Instruction input
        imm : out std_logic_vector(31 downto 0) -- Immediate value output
    );
end entity imm_generator;

architecture behavioral of imm_generator is
    signal opcode : std_logic_vector(6 downto 0);
    signal imm_temp : signed(31 downto 0); -- Temporary signal for immediate value

begin
    opcode <= instr(6 downto 0); -- Extract opcode from instruction
    process (opcode, instr)
    begin
        case opcode is

                -- I-type (addi, lw, lbu)
            when OPCODE_OP_IMM | OPCODE_LOAD | OPCODE_JALR | OPCODE_SYSTEM =>
                imm_temp <= resize(signed(instr(31 downto 20)), 32); -- I-type immediate (12 bits)

                -- S-type (sw, sb)
            when OPCODE_STORE =>
                imm_temp <= resize(signed(instr(31) & instr(30 downto 25) & instr(11 downto 7)), 32); -- S-type immediate (12 bits)

                -- B-type (bne, bge, bnez)
            when OPCODE_BRANCH =>
                imm_temp <= resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32);

                -- U-type (lui)
            when OPCODE_LUI | OPCODE_AUIPC =>
                imm_temp <= signed(instr(31 downto 12) & x"000");

                -- J-type (jal)
            when OPCODE_JAL =>
                imm_temp <= resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32);

            when OPCODE_OP | OPCODE_MISC_MEM =>
                imm_temp <= (others => '0'); -- Set immediate to 0 for reserved opcodes

            when others =>
                imm_temp <= (others => '0'); -- Default case, set immediate to 0
        end case;
    end process;

    imm <= std_logic_vector(imm_temp); -- Output the immediate value

end architecture behavioral;