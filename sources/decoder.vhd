library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.alu_op.all; -- Import ALU operation codes

entity decoder is
    port(
        instr: in std_logic_vector(31 downto 0); -- Instruction input
        opcode: out std_logic_vector(6 downto 0); -- Opcode output
        rd: out std_logic_vector(4 downto 0); -- Destination register output
        funct3: out std_logic_vector(2 downto 0); -- Function3 output
        rs1: out std_logic_vector(4 downto 0); -- Source register 1 output
        rs2: out std_logic_vector(4 downto 0); -- Source register 2 output
        funct7: out std_logic_vector(6 downto 0); -- Function7 output
        imm: out signed(31 downto 0); -- Immediate value output
        alu_op: out std_logic_vector(3 downto 0); -- ALU operation code output
    );
end entity decoder;

architecture behavioral of decoder is
    signal imm_i: std_logic_vector(31 downto 0);

begin
    opcode <= instr(6 downto 0); -- Extract opcode from instruction
    rd <= instr(11 downto 7); -- Extract destination register (rd)
    funct3 <= instr(14 downto 12); -- Extract function3 from instruction
    rs1 <= instr(19 downto 15); -- Extract source register 1 (rs1)
    rs2 <= instr(24 downto 20); -- Extract source register 2 (rs2)
    funct7 <= instr(31 downto 25); -- Extract function7 from instruction

    -- Default ALUOp
    alu_op <= ALU_NOP; -- Default to NOP operation

    process(instr)
        variable opc:std_logic_vector(6 downto 0);
        variable f3:std_logic_vector(2 downto 0);
        variable f7:std_logic_vector(6 downto 0);
    
    begin
        opc := instr(6 downto 0);
        f3 := instr(14 downto 12);
        f7 := instr(31 downto 25);

        case opc is
            when "0010011" => -- I-type(addi)
                case f3 is
                    when "000" => alu_op <= ALU_ADD; --addi
                    when others => alu_op <= ALU_INV; -- Invalid operation
                end case;
            
            when "0110011" => -- R-type(add/sub)
                case f3 is
                    when "000" =>
                        if f7 = "0000000" then
                            alu_op <= ALU_ADD; -- add
                        elsif f7 = "0100000" then
                            alu_op <= ALU_SUB; -- sub
                        else
                            alu_op <= ALU_INV; -- Invalid operation
                        end if;
                    when others => alu_op <= ALU_INV; -- Invalid operation
                end case;
            
            when "0000011" => --lw, lbu
                case f3 is
                    when "000" | "010" => alu_op <= ALU_ADD; -- lw, lbu
                    when others => alu_op <= ALU_INV; -- Invalid operation
                end case;
            
            when "1101111" => --jal
                alu_op <= ALU_PASS; -- jal (no operation, just pass through)
            
            when "1100111" => -- jalr
                alu_op <= ALU_ADD; -- jalr (add rs1 and immediate)
            
            when "0110111" => --lui
                alu_op <= ALU_PASS; -- lui (load upper immediate, no operation)
            
            when others =>
                alu_op <= ALU_INV; -- Default to invalid operation for unsupported opcodes
        end case;
    end process;

end architecture behavioral;