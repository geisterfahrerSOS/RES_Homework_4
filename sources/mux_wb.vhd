library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.wb_sel.all;


entity mux_wb is
    port (
        alu_result   : in std_logic_vector(31 downto 0);
        pc_plus_4    : in std_logic_vector(31 downto 0);
        imm          : in std_logic_vector(31 downto 0);
        wb_sel       : in std_logic_vector(1 downto 0);
        wb_lsu_data : in std_logic_vector(31 downto 0); -- Memory data input
        wb_data      : out std_logic_vector(31 downto 0)
    );
end entity mux_wb;

architecture behavioral of mux_wb is
begin
    process(wb_sel, alu_result, pc_plus_4, imm, wb_lsu_data)
    begin
        case wb_sel is
            when WB_ALU =>
                wb_data <= alu_result;
            when WB_PC_PLUS_4 =>
                wb_data <= pc_plus_4;
            when WB_IMM =>
                wb_data <= imm;
            when WB_MEM =>
                -- Assuming memory data is not provided in this context, set to zero
                wb_data <= wb_lsu_data;
            when others =>
                wb_data <= (others => '0');
        end case;
    end process;
end architecture behavioral;