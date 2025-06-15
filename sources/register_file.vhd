library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        -- Read ports
        rs1_addr: in  std_logic_vector(4 downto 0);
        rs2_addr: in  std_logic_vector(4 downto 0);
        rs1_data: out std_logic_vector(31 downto 0);
        rs2_data: out std_logic_vector(31 downto 0);
        -- Write port
        rd_addr : in  std_logic_vector(4 downto 0);
        rd_data : in  std_logic_vector(31 downto 0);
        rd_we   : in  std_logic
    );
end register_file;

architecture rtl of register_file is
    type register_array is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal registers : register_array;
begin
    -- Read process (combinational)
    read_process: process(rs1_addr, rs2_addr, registers)
    begin
        -- x0 is hardwired to 0
        if (rs1_addr = "00000") then
            rs1_data <= (others => '0');
        else
            rs1_data <= registers(to_integer(unsigned(rs1_addr)));
        end if;

        if (rs2_addr = "00000") then
            rs2_data <= (others => '0');
        else
            rs2_data <= registers(to_integer(unsigned(rs2_addr)));
        end if;
    end process;

    -- Write process (sequential)
    write_process: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all registers to 0
                for i in registers'range loop
                    registers(i) <= (others => '0');
                end loop;
            elsif rd_we = '1' and rd_addr /= "00000" then
                -- Write to register if write enable is active and not writing to x0
                registers(to_integer(unsigned(rd_addr))) <= rd_data;
            end if;
        end if;
    end process;

end rtl;