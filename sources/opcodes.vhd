library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package opcodes is
    -- RISC-V RV32I Main Opcodes (7-bit values)
    -- These constants correspond to the opcode field (bits 6 downto 0)
    -- of RISC-V instructions.

    -- R-Type (Register-Register Operations)
    constant OPCODE_OP       : std_logic_vector(6 downto 0) := "0110011"; -- ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU

    -- I-Type (Immediate Operations)
    constant OPCODE_OP_IMM   : std_logic_vector(6 downto 0) := "0010011"; -- ADDI, SLTI, SLTIU, ANDI, ORI, XORI, SLLI, SRLI, SRAI
    constant OPCODE_LOAD     : std_logic_vector(6 downto 0) := "0000011"; -- LB, LH, LW, LBU, LHU
    constant OPCODE_JALR     : std_logic_vector(6 downto 0) := "1100111"; -- Jump and Link Register (used for RET, indirect jumps)
    constant OPCODE_SYSTEM   : std_logic_vector(6 downto 0) := "1110011"; -- ECALL, EBREAK, CSRR* (System, Environment, CSR)

    -- S-Type (Store Operations)
    constant OPCODE_STORE    : std_logic_vector(6 downto 0) := "0100011"; -- SB, SH, SW

    -- B-Type (Branch Operations)
    constant OPCODE_BRANCH   : std_logic_vector(6 downto 0) := "1100011"; -- BEQ, BNE, BLT, BGE, BLTU, BGEU

    -- U-Type (Upper Immediate Operations)
    constant OPCODE_LUI      : std_logic_vector(6 downto 0) := "0110111"; -- Load Upper Immediate
    constant OPCODE_AUIPC    : std_logic_vector(6 downto 0) := "0010111"; -- Add Upper Immediate to PC

    -- J-Type (Jump Operations)
    constant OPCODE_JAL      : std_logic_vector(6 downto 0) := "1101111"; -- Jump and Link (used for direct jumps, function calls)

    -- Reserved/Unused Opcode (often used for FENCE, FENCE.I or other extensions)
    constant OPCODE_MISC_MEM : std_logic_vector(6 downto 0) := "0001111"; -- FENCE, FENCE.I (memory ordering)

    -- Note: This list covers the most common opcodes from the RV32I base instruction set.
    -- Other instruction set extensions (M for multiplication/division, A for atomics, F/D for floating point, C for compressed)
    -- would utilize different opcode bit patterns or extensions.

end package opcodes;