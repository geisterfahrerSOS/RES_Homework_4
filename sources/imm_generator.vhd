library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity imm_generator is
    port (
        instr: in std_logic_vector(31 downto 0); -- Instruction input
        imm: out signed(31 downto 0) -- Immediate value output
    );
end entity imm_generator;

architecture behavioral of imm_generator is
    signal opcode: std_logic_vector(6 downto 0);
    signal imm: std_logic_vector(31 downto 0);

begin
    opcode <= instr(6 downto 0); -- Extract opcode from instruction

    process(instr)
    begin
        case opcode is

            -- I-type (addi, lw, lbu)
            when "0010011" | "0000011" =>
                imm <= resize(signed(instr(31 downto 20)), 32); -- I-type immediate (12 bits)
            
            -- S-type (sw, sb)
            when "01000011" =>
                imm <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32); -- S-type immediate (12 bits)

            -- B-type (bne, bge, bnez)
            when "1100011" =>
                imm <= resize(signed(instr(31)&instr(7)&instr(30 downto 25)&instr(11 downto 8)&'0'),32
                );
            
            -- U-type (lui)
            when "0110111" =>
                imm <= signed(instr(31 downto 12) & x"000");
            
            -- J-type (jal)
            when "1101111" =>
                imm <= resize(signed(instr(32)&instr(19 downto 12)&instr(20)&instr(30 downto 21)& '0'), 32
                );
            
            when others =>
                imm <= (others => '0'); -- Default case, set immediate to 0

        end case;
    end process;

    imm_out <= imm; -- Output the immediate value

end architecture behavioral;


                