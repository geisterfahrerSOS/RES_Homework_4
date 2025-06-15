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
    );
end entity decoder;

architecture behavioral of decoder is
begin
    -- Assign instruction fields to outputs
    opcode <= instr(6 downto 0); -- Extract opcode from instruction
    rd <= instr(11 downto 7); -- Extract destination register (rd)
    funct3 <= instr(14 downto 12); -- Extract function3 from instruction
    rs1 <= instr(19 downto 15); -- Extract source register 1 (rs1)
    rs2 <= instr(24 downto 20); -- Extract source register 2 (rs2)
    funct7 <= instr(31 downto 25); -- Extract function7 from instruction

end architecture behavioral;