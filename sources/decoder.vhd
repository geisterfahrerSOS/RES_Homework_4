library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.alu_op.all; -- Import ALU operation codes
use work.opcodes.all; -- Import opcode definitions
use work.branch_sel.all; -- Import branch selector codes
use work.wb_sel.all; -- Import write-back select codes

entity decoder is
    port(
        instr: in std_logic_vector(31 downto 0); -- Instruction input
        opcode: out std_logic_vector(6 downto 0); -- Opcode output
        rd: out std_logic_vector(4 downto 0); -- Destination register output
        funct3: out std_logic_vector(2 downto 0); -- Function3 output
        rs1: out std_logic_vector(4 downto 0); -- Source register 1 output
        rs2: out std_logic_vector(4 downto 0); -- Source register 2 output
        funct7: out std_logic_vector(6 downto 0); -- Function7 output
        alu_op: out std_logic_vector(3 downto 0); -- ALU operation code output
        wb_sel: out std_logic_vector(1 downto 0); -- Write-back select output -- maybe not needed due to opcode info
        pc_sel : out std_logic_vector(1 downto 0) -- PC select output
    );
end entity decoder;

architecture behavioral of decoder is
    signal imm_i: std_logic_vector(31 downto 0);
    signal internal_opcode: std_logic_vector(6 downto 0);
    signal internal_funct3: std_logic_vector(2 downto 0);

begin
    -- Assign instruction fields to outputs
    opcode <= instr(6 downto 0); -- Extract opcode from instruction
    rd <= instr(11 downto 7); -- Extract destination register (rd)
    funct3 <= instr(14 downto 12); -- Extract function3 from instruction
    rs1 <= instr(19 downto 15); -- Extract source register 1 (rs1)
    rs2 <= instr(24 downto 20); -- Extract source register 2 (rs2)
    funct7 <= instr(31 downto 25); -- Extract function7 from instruction

    -- Default ALUOp
    alu_op <= ALU_NOP; -- Default to NOP operation

    process(instr)
    begin
        case opcode is
            when OPCODE_OP =>
            -- R-type instructions (add, sub, and, or, etc.)
                case funct3 is
                    when "000" =>
                        if funct7 = "0000000" then
                            alu_op <= ALU_ADD; -- add
                        elsif funct7 = "0100000" then
                            alu_op <= ALU_SUB; -- sub
                        else
                            alu_op <= ALU_INV; -- Invalid operation
                        end if;
                    when "111" => alu_op <= ALU_AND; -- and
                    when "110" => alu_op <= ALU_OR; -- or
                    when "100" => alu_op <= ALU_XOR; -- xor
                    when "001" => alu_op <= ALU_SLL; -- sll
                    when "101" =>
                        if funct7 = "0000000" then
                            alu_op <= ALU_SRL; -- srl
                        elsif funct7 = "0100000" then
                            alu_op <= ALU_SRA; -- sra
                        else
                            alu_op <= ALU_INV; -- Invalid operation
                        end if;
                    when "010" => alu_op <= ALU_SLT; -- slt
                    when "011" => alu_op <= ALU_SLTU; -- sltu
                    when others => alu_op <= ALU_INV; -- Default to invalid operation
                end case;
                wb_sel <= WB_ALU; -- Write back ALU result for R-type instructions

            when OPCODE_OP_IMM =>
            -- I-type instructions (addi, slti, andi, ori, etc.)
                case funct3 is
                    when "000" => alu_op <= ALU_ADD; -- addi
                    when "111" => alu_op <= ALU_AND; -- andi
                    when "110" => alu_op <= ALU_OR; -- ori
                    when "100" => alu_op <= ALU_XOR; -- xori
                    when "001" => alu_op <= ALU_SLL; -- slli
                    when "101" =>
                        if funct7 = "0000000" then
                            alu_op <= ALU_SRL; -- srli
                        elsif funct7 = "0100000" then
                            alu_op <= ALU_SRA; -- srai
                        else
                            alu_op <= ALU_INV; -- Invalid operation
                        end if;
                    when "010" => alu_op <= ALU_SLT; -- slti
                    when "011" => alu_op <= ALU_SLTU; -- sltiu
                    when others => alu_op <= ALU_INV; -- Default to invalid operation
                end case;

            when OPCODE_LOAD =>
            -- Load instructions (lw, lb, lbu, lh, lhu)
                case funct3 is
                    when "000" | "001" => alu_op <= ALU_ADD; -- lw, lb
                    when "010" => alu_op <= ALU_ADD; -- lbu
                    when "100" => alu_op <= ALU_ADD; -- lh
                    when "101" => alu_op <= ALU_ADD; -- lhu
                    when others => alu_op <= ALU_INV; -- Default to invalid operation
                end case;

            when OPCODE_JALR =>
                -- J-type instructions (jalr)
                alu_op <= ALU_NOP; -- Jump and Link Register
                wb_sel <= WB_PC_PLUS_4; -- Write back PC + 4 for JALR
                
            when OPCODE_SYSTEM =>
                -- Not implemented

            when OPCODE_STORE =>
                -- Not implemented no RAM exists

            when OPCODE_BRANCH =>
                -- Do nothing handled in branch control unit it gets the two registers and the funct3

            when OPCODE_LUI =>
                wb_sel <= WB_IMM; -- Write back immediate value for LUI

            when OPCODE_AUIPC =>
                -- adding of pc and immediate handled in the ALU
                alu_op <= ALU_ADD; -- Add Upper Immediate to PC
                wb_sel <= WB_ALU; -- Write back ALU result for AUIPC

            when OPCODE_JAL =>
                -- J-type instructions (jal)
                -- write PC + 4 to the register
                -- add an offset to the PC
                wb_sel <= WB_PC_PLUS_4; -- Write back PC + 4 for JAL


            when OPCODE_MISC_MEM =>
                -- Not implemented

            when others =>
                alu_op <= ALU_INV; -- Default to invalid operation
                
        end case;
    end process;

end architecture behavioral;