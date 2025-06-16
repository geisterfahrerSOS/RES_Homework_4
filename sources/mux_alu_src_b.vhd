library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.opcodes.all; -- Import opcode definitions


-- This entity selects the immediate value or register data based on the opcode
entity mux_alu_src_b is
    port(
        rs2_data: in std_logic_vector(31 downto 0); -- Data from register rd2
        imm: in std_logic_vector(31 downto 0); -- Immediate value
        src_b_sel: in std_logic;
        src_b: out std_logic_vector(31 downto 0) -- mux output
    );
end entity mux_alu_src_b;

architecture behavioral of mux_alu_src_b is
begin

    process(src_b_sel, imm, rs2_data)
    begin
        if src_b_sel = '0' then
            src_b <= imm; -- Select immediate value
        else
            src_b <= rs2_data; -- Select register data
        end if;
    end process;

end architecture behavioral;