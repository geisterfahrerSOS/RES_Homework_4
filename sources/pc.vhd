library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc is
    port (
        clk: in std_logic;
        reset: in std_logic;
        PCSel: in std_logic_vector(1 downto 0); -- 2-bit selector: 00 PC+4, 01 PC+imm(br / jal), 10 rs1+imm (rind/jalr), 11 absoulte jump (jabs)
        imm: in signed(31 downto 0); -- Immediate value from instruction
        rs1: in signed(31 downto 0); -- register source 1 (jalr)
        jabs: in signed(31 downto 0) -- Absolute jump address for JAL
        pc_out: out std_logic_vector(31 downto 0) -- current PC value
    );
end entity pc;

architecture behavioral of pc is
    signal pc_reg: signed(31 downto 0) := (others => '0'); -- PC register initialized to 0
    signal pc_next: signed(31 downto 0); -- Next PC value
    signal pc_plus_4: signed(31 downto 0); -- PC + 4 value
    signal pc_plus_imm: signed(31 downto 0); -- PC + immediate value
    signal rs1_plus_imm: signed(31 downto 0); -- rs1 + immediate value

begin
    
    -- Calculate PC + 4
    pc_plus_4 <= std_logic_vector(unsigned(pc_reg) + 4);

    -- Calculate PC + immediate value
    pc_plus_imm <= std_logic_vector(unsigned(pc_reg) + unsigned(imm));

    -- Calculate rs1 + immediate value
    rs1_plus_imm <= std_logic_vector(unsigned(rs1) + unsigned(imm));

    -- Process to update PC based on PCSel
    process(PCSel, pc_plus_4, pc_plus_imm, rs1_plus_imm, jabs)
    begin
        case PCSel is
            when "00" =>  -- PC + 4
                pc_next <= pc_plus_4;
            when "01" =>  -- PC + immediate (branch/jal)
                pc_next <= pc_plus_imm;
            when "10" =>  -- rs1 + immediate (jalr)
                pc_next <= rs1_plus_imm;
            when "11" =>  -- Absolute jump (jabs)
                pc_next <= jabs;
            when others =>
                pc_next <= pc_reg; -- Default case, keep current PC
        end case;
    end process;

    -- Process to update PC register on clock edge or reset
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0'); -- Reset PC to 0
            else
                pc_reg <= pc_next; -- Update PC with the next value
            end if;
        end if;
    end process;

    -- Output the current PC value
    pc_out <= std_logic_vector(pc_reg);
end architecture behavioral;
