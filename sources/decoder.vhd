library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder is
    port(
        opcode: in std_logic_vector(6 downto 0); -- Opcode input
        funct3: in std_logic_vector(2 downto 0); -- Function code input
        funct7: in std_logic_vector(6 downto 0); -- Function code input
        RegWrite: out std_logic; -- Register write enable
        ALUSrc: out std_logic; -- ALU source select
        MemRead: out std_logic; -- Memory read enable
        MemWrite: out std_logic; -- Memory write enable
        Branch: out std_logic; -- Branch enable
        Jump: out std_logic; -- Jump enable
        ALUOp: out std_logic_vector(3 downto 0); -- ALU operation code
        ImmSel: out std_logic_vector(2 downto 0); -- Immediate selection
    );
end entity decoder;

architecture behavioral of decoder is
begin
   process(opcode, funct3, funct7)
   begin
    -- Defaults
    RegWrite <= '0';
    ALUSrc <= '0';
    MemRead <= '0';
    MemWrite <= '0';
    Branch <= '0';
    Jump <= '0';
    ALUOp <= "0000"; -- Default ALU operation
    ImmSel <= "000"; -- Default immediate selection

    case opcode is
        
        --I-Type: addi
        when "0010011" =>
            RegWrite <= '1';
            ALUSrc <= '1';
            ImmSel <= "000"; -- I-type immediate
            case funct3 is 
                when "000" => ALUOp <= "0000"; --ADDI
                when others => ALUOp <= "1111"; -- Default ALU operation for unsupported funct3
            end case;

        --I-Type: lw, lbu
        when "0000011" =>
            RegWrite <= '1';
            ALUSrc <= '1';
            MemRead <= '1';
            ImmSel <= "000"; -- I-type immediate
            case funct3 is 
                when "010" => ALUOp <= "0010"; -- LW (addr = res1 + imm)
                when "100" => ALUOp <= "0100"; -- LBU (same address logic)
                when others => ALUOp <= "1111"; -- Default ALU operation for unsupported funct3
            end case;

        --S-Type: sw, sb
        when "0100011" =>
            ALUSrc <= '1';
            MemWrite <= '1';
            ImmSel <= "001"; -- S-type immediate
            case funct3 is 
                when "010" => ALUOp <= "0010"; -- SW (addr = res1 + imm)
                when "000" => ALUOp <= "0000"; -- SB (same address logic)
                when others => ALUOp <= "1111"; -- Default ALU operation for unsupported funct3
            end case;