library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.opcodes.all; -- Import opcode definitions


-- This mux selects between the PC value or register data based on the opcode
entity mux_alu_src_a is
    port(
        rs1_data: in std_logic_vector(31 downto 0); -- Data from register rs1
        pc: in std_logic_vector(31 downto 0); -- PC
        src_a_sel: in std_logic;
        src_a: out std_logic_vector(31 downto 0) -- mux output
    );
end entity mux_alu_src_a;

architecture behavioral of mux_alu_src_a is
begin

    process(src_a_sel)
    begin
        if src_a_sel = '0' then
            src_a <= rs1_data; -- Select register data
        else
            src_a <= pc; -- Select PC value
        end if;
        
    end process;

end architecture behavioral;