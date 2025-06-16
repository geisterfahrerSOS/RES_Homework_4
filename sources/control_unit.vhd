library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opcodes.all; -- Import opcode definitions
use work.alu_op.all; -- Import ALU operation codes
use work.wb_sel.all; -- Import write-back select definitions

entity control_unit is
    port (
        clk : in std_logic;
        rst : in std_logic;
        opcode : in std_logic_vector(6 downto 0); -- Opcode output
        rd : in std_logic_vector(4 downto 0); -- Destination register output
        funct3 : in std_logic_vector(2 downto 0); -- Function3 output
        rs1 : in std_logic_vector(4 downto 0); -- Source register 1 output
        rs2 : in std_logic_vector(4 downto 0); -- Source register 2 output
        funct7 : in std_logic_vector(6 downto 0); -- Function7 output
        src_a_sel: out std_logic;
        src_b_sel: out std_logic;
        rd_we : out std_logic; -- Write enable for destination register
        alu_op : out std_logic_vector(3 downto 0); -- ALU operation code output
        wb_sel : out std_logic_vector(1 downto 0); -- Write-back select output -- maybe not needed due to opcode info
        pc_sel : out std_logic_vector(1 downto 0); -- PC select output
        branch_sel: out std_logic_vector(2 downto 0) -- Branch select output
    );
end control_unit;

architecture behavioral of control_unit is
begin
    process (clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                
            else
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
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '0'; -- Select rs2 for ALU source B
                        wb_sel <= WB_ALU; -- Write back ALU result for R-type instructions
                        pc_sel <= "00"; -- No PC change for R-type instructions
                        rd_we <= '1'; -- Enable write to destination register

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
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '0'; -- Select immediate for ALU source B
                        wb_sel <= WB_ALU; -- Write back ALU result for I-type instructions
                        pc_sel <= "00"; -- No PC change for I-type instructions
                        rd_we <= '1'; -- Enable write to destination register

                    when OPCODE_LOAD =>
                        -- Load instructions (lw, lb, lbu, lh, lhu)
                        case funct3 is
                            when "000" | "001" => alu_op <= ALU_ADD; -- lw, lb
                            when "010" => alu_op <= ALU_ADD; -- lbu
                            when "100" => alu_op <= ALU_ADD; -- lh
                            when "101" => alu_op <= ALU_ADD; -- lhu
                            when others => alu_op <= ALU_INV; -- Default to invalid operation
                        end case;
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '0'; -- Select immediate for ALU source B
                        wb_sel <= WB_MEM; -- Write back memory result for load instructions
                        pc_sel <= "00"; -- No PC change for load instructions
                        rd_we <= '1'; -- Enable write to destination register


                    when OPCODE_JALR =>
                        -- J-type instructions (jalr)
                        alu_op <= ALU_NOP; -- Jump and Link Register
                        wb_sel <= WB_PC_PLUS_4; -- Write back PC + 4 for JALR
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '0'; -- Select immediate for ALU source B
                        pc_sel <= "01"; -- Set PC to rs1 + immediate
                        rd_we <= '1'; -- Enable write to destination register


                    when OPCODE_SYSTEM =>
                        -- Not implemented

                    when OPCODE_STORE =>
                        -- Not implemented no RAM exists
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '1'; -- Select rs2 for ALU source B
                        alu_op <= ALU_ADD; -- Add rs1 and immediate for store address calculation
                        wb_sel <= WB_ALU; -- Write back ALU result for store address
                        pc_sel <= "00"; -- No PC change for store instructions
                        rd_we <= '0'; -- Disable write to destination register for store instructions

                    when OPCODE_BRANCH =>
                        -- Do nothing handled in branch control unit it gets the two registers and the funct3
                        alu_op <= ALU_NOP; -- No ALU operation for branches
                        wb_sel <= WB_IMM; -- No write back for branches
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '1'; -- Select rs2 for ALU source B
                        pc_sel <= "10"; -- Set PC to branch target
                        rd_we <= '0'; -- Disable write to destination register for branch instructions

                    when OPCODE_LUI =>
                        wb_sel <= WB_IMM; -- Write back immediate value for LUI
                        src_a_sel <= '0'; -- Select immediate for ALU source A
                        src_b_sel <= '0'; -- No second source for ALU
                        alu_op <= ALU_NOP; -- No ALU operation for LUI
                        pc_sel <= "00"; -- No PC change for LUI
                        rd_we <= '1'; -- Enable write to destination register for LUI

                    when OPCODE_AUIPC =>
                        -- adding of pc and immediate handled in the ALU
                        alu_op <= ALU_ADD; -- Add Upper Immediate to PC
                        wb_sel <= WB_ALU; -- Write back ALU result for AUIPC
                        src_a_sel <= '1'; -- Select PC for ALU source A
                        src_b_sel <= '0'; -- Select immediate for ALU source B
                        pc_sel <= "00"; -- No PC change for AUIPC
                        rd_we <= '1'; -- Enable write to destination register for AUIPC

                    when OPCODE_JAL =>
                        -- J-type instructions (jal)
                        -- write PC + 4 to the register
                        -- add an offset to the PC
                        wb_sel <= WB_PC_PLUS_4; -- Write back PC + 4 for JAL
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '0'; -- Select immediate for ALU source B
                        alu_op <= ALU_NOP; -- No ALU operation for JAL
                        pc_sel <= "01"; -- Set PC to immediate offset
                        rd_we <= '1'; -- Enable write to destination register for JAL

                    when OPCODE_MISC_MEM =>
                        -- Not implemented
                        src_a_sel <= '0'; -- Select rs1 for ALU source A
                        src_b_sel <= '0'; -- No second source for ALU
                        alu_op <= ALU_NOP; -- No ALU operation for MISC_MEM
                        wb_sel <= WB_ALU; -- Write back ALU result for MISC_MEM
                        pc_sel <= "00"; -- No PC change for MISC_MEM
                        rd_we <= '0'; -- Disable write to destination register for MISC_MEM

                    when others =>
                        alu_op <= ALU_INV; -- Default to invalid operation
                        wb_sel <= WB_ALU; -- Default write back ALU result
                        src_a_sel <= '0'; -- Default select rs1 for ALU source A
                        src_b_sel <= '0'; -- Default select rs2 for ALU source B
                        pc_sel <= "00"; -- Default no PC change
                        rd_we <= '0'; -- Default disable write to destination register

                end case;
            end if;
        end if;
    end process;

end behavioral;