library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.opcodes.all; -- Import opcode definitions

entity lsu is
    port (
        clk : in std_logic;
        rst : in std_logic;
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        addr : in std_logic_vector(31 downto 0);
        data_reg_in : in std_logic_vector(31 downto 0);
        data_mem_in : in std_logic_vector(31 downto 0);
        data_reg_out : out std_logic_vector(31 downto 0);
        data_mem_out : out std_logic_vector(31 downto 0);
        rom_data_in : in std_logic_vector(31 downto 0); -- Input data from memory (for load operations)
        byte_enable : out std_logic_vector(3 downto 0); -- Byte enable for store operations
        mem_we : out std_logic -- Write enable signal for store operations
    );
end lsu;

architecture Behavioral of lsu is
    constant ROM_MEMORY_END : std_logic_vector(31 downto 0) := x"00008000"; -- End address of ROM memory
begin
    process (clk, rst, opcode, funct3, addr, data_reg_in, data_mem_in, rom_data_in)
    variable temp_data_in : std_logic_vector(31 downto 0);
    begin

        if rst = '1' then
            data_reg_out <= (others => '0');
            data_mem_out <= (others => '0');
            byte_enable <= (others => '0');
            mem_we <= '0'; -- Clear write enable on reset
        else
            data_reg_out <= (others => '0');
            data_mem_out <= (others => '0');
            byte_enable <= (others => '0');
            mem_we <= '0';
            if opcode = OPCODE_STORE then -- Store instructions
            mem_we <= '1'; -- Set write enable for store operations
                data_mem_out <= data_reg_in; -- Output data to memory
                case funct3 is
                    when "000" => -- SB (Store Byte)
                        case addr(1 downto 0) is
                            when "00" => byte_enable <= "0001"; -- Enable byte 0
                            when "01" => byte_enable <= "0010"; -- Enable byte 1
                            when "10" => byte_enable <= "0100"; -- Enable byte 2
                            when "11" => byte_enable <= "1000"; -- Enable byte 3
                            when others => byte_enable <= (others => '0'); -- Invalid address
                        end case;
                    when "001" => -- SH (Store Halfword)
                        if addr(1) = '0' then
                            byte_enable <= "0011"; -- Enable bytes 0 and 1
                        else
                            byte_enable <= "1100"; -- Enable bytes 2 and 3
                        end if;
                    when "010" => -- SW (Store Word)
                        byte_enable <= "1111"; -- All bytes enabled for word store
                    when others =>
                        byte_enable <= (others => '0'); -- Invalid func3
                        mem_we <= '0'; -- Clear write enable for invalid operations
                end case;
            elsif opcode = OPCODE_LOAD then -- Load instructions
                report "Adress: x" & to_hstring(to_bitvector(addr));
                if addr < ROM_MEMORY_END then -- Check if address is in ROM range this is for reading the hello world ascii string
                    report "Loading from ROM";
                    temp_data_in := rom_data_in; -- Use ROM data for load operations
                else
                    report "Loading from RAM";
                    temp_data_in := data_mem_in; -- Use RAM data for load operations
                end if;
                -- For load operations, we assume data_mem_in is the memory content read from the RAM
                case funct3 is
                    when "000" => -- LB (Load Byte, sign-extended)
                        case addr(1 downto 0) is
                            when "00" => data_reg_out <= std_logic_vector(resize(signed(temp_data_in(7 downto 0)), 32));
                            when "01" => data_reg_out <= std_logic_vector(resize(signed(temp_data_in(15 downto 8)), 32));
                            when "10" => data_reg_out <= std_logic_vector(resize(signed(temp_data_in(23 downto 16)), 32));
                            when "11" => data_reg_out <= std_logic_vector(resize(signed(temp_data_in(31 downto 24)), 32));
                            when others => data_reg_out <= (others => '0');
                        end case;
                    when "001" => -- LH (Load Halfword, sign-extended)
                        if addr(1) = '0' then
                            data_reg_out <= std_logic_vector(resize(signed(temp_data_in(15 downto 0)), 32));
                        else
                            data_reg_out <= std_logic_vector(resize(signed(temp_data_in(31 downto 16)), 32));
                        end if;
                    when "010" => -- LW (Load Word)
                        data_reg_out <= temp_data_in;
                    when "100" => -- LBU (Load Byte, zero-extended)
                        case addr(1 downto 0) is
                            when "00" => data_reg_out <= (31 downto 8 => '0') & temp_data_in(7 downto 0);
                            when "01" => data_reg_out <= (31 downto 8 => '0') & temp_data_in(15 downto 8);
                            when "10" => data_reg_out <= (31 downto 8 => '0') & temp_data_in(23 downto 16);
                            when "11" => data_reg_out <= (31 downto 8 => '0') & temp_data_in(31 downto 24);
                            when others => data_reg_out <= (others => '0');
                        end case;
                    when "101" => -- LHU (Load Halfword, zero-extended)
                        if addr(1) = '0' then
                            data_reg_out <= (31 downto 16 => '0') & temp_data_in(15 downto 0);
                        else
                            data_reg_out <= (31 downto 16 => '0') & temp_data_in(31 downto 16);
                        end if;
                    when others =>
                        data_reg_out <= (others => '0');
                end case;
                mem_we <= '0'; -- Clear write enable for load operations
            end if;
        end if;
    end process;
end Behavioral;