library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch_logic is
    port (
        rs1: in signed(31 downto 0); -- Source register 1
        rs2: in signed(31 downto 0); -- Source register 2
        branch_sel: in std_logic_vector(2 downto 0); -- Branch selector
        branch_taken: out std_logic -- Branch taken output
    );
end entity branch_logic;

architecture behavioral of branch_logic is
begin
    process(rs1, rs2, branch_sel)
    begin
        case branch_sel is
            when "000" => -- BEQ (Branch if Equal)
                if rs1 = rs2 then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when "001" => -- BNE (Branch if Not Equal)
                if rs1 /= rs2 then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            
            when "010" => -- BLT (Branch if Less Than)
                if rs1 < rs2 then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            
            when "011" => -- BGE (Branch if Greater Than or Equal)
                if rs1 >= rs2 then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            
            when "100" => -- BNEZ (Branch if Not Equal to Zero)
                if rs1 /= to_signed(0, 32) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when others =>
                branch_taken <= '0'; -- Default case, no branch taken
        end case;
    end process;
end architecture behavioral;

