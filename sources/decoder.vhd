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
        branch_sel: out std_logic_vector(2 downto 0) -- Branch selector output
    );
end entity decoder;

architecture behavioral of decoder is
    signal imm_i: std_logic_vector(31 downto 0);
    signal internal_opcode: std_logic_vector(6 downto 0);
    signal internal_funct3: std_logic_vector(2 downto 0);

    --Component Declaration of branch_logic
    component branch_logic
        port(
            opcode: in std_logic_vector(6 downto 0); -- Opcode input
            funct3: in std_logic_vector(2 downto 0); -- Function3 input
            branch_sel: out std_logic_vector(2 downto 0) -- Branch selector output
        );
    end component;

begin
    -- Assign instruction fields to outputs
    opcode <= instr(6 downto 0); -- Extract opcode from instruction
    rd <= instr(11 downto 7); -- Extract destination register (rd)
    funct3 <= instr(14 downto 12); -- Extract function3 from instruction
    rs1 <= instr(19 downto 15); -- Extract source register 1 (rs1)
    rs2 <= instr(24 downto 20); -- Extract source register 2 (rs2)
    funct7 <= instr(31 downto 25); -- Extract function7 from instruction

    internal_opcode <= instr(6 downto 0); -- Internal opcode for branch logic
    internal_funct3 <= instr(14 downto 12); -- Internal funct3 for branch logic

    -- Default ALUOp
    alu_op <= ALU_NOP; -- Default to NOP operation

    -- Initiate branch logic
    branch_logic_inst: branch_logic
        port map(
            opcode => internal_opcode,
            funct3 => internal_funct3,
            branch_sel => branch_sel
        );
    
    -- ALU decoding
    process(instr)
        variable opc: std_logic_vector(6 downto 0);
        variable f3: std_logic_vector(2 downto 0);
        variable f7: std_logic_vector(6 downto 0);

    begin
        opc:= instr(6 downto 0);
        f3 := instr(14 downto 12);
        f7 := instr(31 downto 25);

        case opc is
            when "0010011" => -- I-type (addi)
                case f3 is
                    when "000" => alu_op <= ALU_ADD; -- addi
                    when others => alu_op <= ALU_INV;
                end case;
            
            when "0110011" => -- R-type (add, sub)
                case f3 is
                    when "000" =>
                        if f7 = "0000000" then
                            alu_op <= ALU_ADD; -- add
                        elsif f7 = "0100000" then
                            alu_op <= ALU_SUB;
                        else
                            alu_op <= ALU_INV; -- Invalid operation
                        end if;
                    when others => alu_op <= ALU_INV; -- Other R-type operations
                end case;
            
            when "0000011" => -- Load (lw, lb, lbu)
                case f3 is
                    when "000" | "010" => alu_op <= ALU_ADD; -- lw, lbu
                    when others => alu_op <= ALU_INV; -- Invalid operation
                end case;

            when "1101111" => -- J-type (jal)
                alu_op <= ALU_PASS;
            
            when "1100111" => -- J-type (jalr)
                alu_op <= ALU_JALR;

            when "0110111" => -- U-type (lui)
                alu_op <= ALU_PASS;

            when others =>
                alu_op <= ALU_INV; -- Default to invalid operation
            
        end case;
    end process;

end architecture behavioral;