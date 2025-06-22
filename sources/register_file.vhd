library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port (
        clk : in std_logic;
        rst : in std_logic;
        -- Read ports
        rs1_addr : in std_logic_vector(4 downto 0);
        rs2_addr : in std_logic_vector(4 downto 0);
        rs1_data : out std_logic_vector(31 downto 0);
        rs2_data : out std_logic_vector(31 downto 0);
        -- Write port
        rd_addr : in std_logic_vector(4 downto 0);
        rd_data : in std_logic_vector(31 downto 0);
        rd_we : in std_logic
    );
end register_file;

architecture rtl of register_file is
    type register_array is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal registers : register_array;
    constant SP_INITIAL : std_logic_vector(31 downto 0) := x"02000000"; -- Initial value for stack pointer (sp)
begin
    -- Write process (sequential)
    write_process : process (clk)
    begin
        if falling_edge(clk) then
            if rst = '1' then
                -- Reset all registers to 0
                for i in registers'range loop
                    if i = 2 then -- Check if it's sp (x2)
                        registers(i) <= SP_INITIAL; -- Initialize sp to the defined RAM_TOP_ADDRESS
                    else
                        registers(i) <= (others => '0'); -- Initialize other registers to 0
                    end if;
                end loop;
            elsif rd_we = '1' and rd_addr /= "00000" then
                -- Write to register if write enable is active and not writing to x0
                registers(to_integer(unsigned(rd_addr))) <= rd_data;
            end if;
        end if;
    end process;
    rs1_data <= (others => '0') when rs1_addr = "00000" else
        registers(to_integer(unsigned(rs1_addr)));

    rs2_data <= (others => '0') when rs2_addr = "00000" else
        registers(to_integer(unsigned(rs2_addr)));

end rtl;