library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.pc_sel.all;

entity mux_pc is
    port (
        clk: in std_logic;
        reset: in std_logic;
        pc_sel: in std_logic_vector(1 downto 0); -- 2-bit selector: 00 PC+4, 01 PC+imm(br / jal), 10 rs1+imm (rind/jalr), 11 absoulte jump (jabs)
        pc: in std_logic_vector(31 downto 0); -- Current PC value
        imm: in std_logic_vector(31 downto 0); -- Immediate value from instruction
        rs1: in std_logic_vector(31 downto 0); -- register source 1 (jalr)
        pc_next: out std_logic_vector(31 downto 0) -- next pc value
    );
end entity mux_pc;

architecture behavioral of mux_pc is
begin
    
    -- Calculate PC + 4
    pc_plus_4 <= std_logic_vector(unsigned(pc_reg) + 4);

    -- Calculate PC + immediate value
    pc_plus_imm <= std_logic_vector(unsigned(pc_reg) + unsigned(imm));

    -- Calculate rs1 + immediate value
    rs1_plus_imm <= std_logic_vector(unsigned(rs1) + unsigned(imm));

    -- Process to update PC based on PCSel
    process(pc_sel, pc_plus_4, pc_plus_imm, rs1_plus_imm, jabs)
    begin
        case pc_sel is
            when PC_PLUS_4 =>  -- PC + 4
                pc_next <= pc_plus_4;
            when 
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
