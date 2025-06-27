library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.branch_sel.all;

entity branch_logic is
    port (
        rs1_data: in std_logic_vector(31 downto 0); -- Source register 1
        rs2_data: in std_logic_vector(31 downto 0); -- Source register 2
        branch_sel: in std_logic_vector(2 downto 0); -- Branch selector aka funct3 from decoder
        branch_cond: out std_logic -- Branch taken output 1 for branch taken, 0 for not taken
    );
end entity branch_logic;

architecture behavioral of branch_logic is
begin
    process(rs1_data, rs2_data, branch_sel)
    begin
        case branch_sel is
            when BEQ => -- BEQ (Branch if Equal)
                if rs1_data = rs2_data then
                    branch_cond <= '1';
                else
                    branch_cond <= '0';
                end if;

            when BNE => -- BNE (Branch if Not Equal)
                if rs1_data /= rs2_data then
                    branch_cond <= '1';
                else
                    branch_cond <= '0';
                end if;
            
            when BLT => -- BLT (Branch if Less Than)
                if rs1_data < rs2_data then
                    branch_cond <= '1';
                else
                    branch_cond <= '0';
                end if;
            
            when BGE => -- BGE (Branch if Greater Than or Equal)
                if rs1_data >= rs2_data then
                    branch_cond <= '1';
                else
                    branch_cond <= '0';
                end if;
            
            when BGEU => -- BGEU (Branch if Greater Than or Equal Unsigned)
                if unsigned(rs1_data) >= unsigned(rs2_data) then
                    branch_cond <= '1';
                else
                    branch_cond <= '0';
                end if;

            when others =>
                branch_cond <= '0'; -- Default case, no branch taken
        end case;
    end process;
end architecture behavioral;

