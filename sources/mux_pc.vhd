library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.pc_sel.all;

entity mux_pc is
    port (
        clk : in std_logic;
        reset : in std_logic;
        pc_sel : in std_logic_vector(1 downto 0); -- 2-bit selector: 00 PC+4, 01 PC+imm(br / jal), 10 rs1+imm (rind/jalr), 11 absoulte jump (jabs)
        branch_cond : in std_logic; -- Branch condition signal
        imm : in std_logic_vector(31 downto 0); -- Immediate value from instruction
        rs1 : in std_logic_vector(31 downto 0); -- register source 1 (jalr)
        pc_out : out std_logic_vector(31 downto 0) -- next pc value
    );
end entity mux_pc;

architecture behavioral of mux_pc is
    signal internal_pc_reg : std_logic_vector(31 downto 0) := (others => '0'); -- The actual PC register
    signal pc_next : std_logic_vector(31 downto 0); -- Next PC value
    begin
    -- Process to update PC based on PCSel
    process (all)
    begin
        case pc_sel is
            when PC_PLUS_4 => -- PC + 4
                pc_next <= std_logic_vector(unsigned(internal_pc_reg) + 4);
            when PC_JABS =>
                pc_next <= (others => '0'); -- Placeholder for absolute jump, to be defined
            when PC_JALR => -- rs1 + immediate (jalr)
                pc_next <= std_logic_vector(unsigned(rs1) + unsigned(imm));
                pc_next(0) <= '0'; -- Ensure the least significant bit is 0 for jalr
            when PC_BR => -- PC + immediate (branch/jal)
                if branch_cond = '1' then
                    pc_next <= std_logic_vector(unsigned(internal_pc_reg) + unsigned(imm));
                else
                    pc_next <= std_logic_vector(unsigned(internal_pc_reg) + 4); -- Fall through if branch not taken
                end if;
            when others =>
                pc_next <= (others => '0'); -- Default case, keep current PC
        end case;
    end process;

    -- Process to update PC register on clock edge or reset
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_out <= (others => '0'); -- Reset PC to 0
            else
                internal_pc_reg <= pc_next; -- Update PC with the next value
            end if;
        end if;
    end process;

    -- Output the current PC value
    pc_out <= internal_pc_reg;
end architecture behavioral;