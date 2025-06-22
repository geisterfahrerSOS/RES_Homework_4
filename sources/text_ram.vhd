library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity text_ram is
    port (
        clk: in std_logic;
        -- Port A: write side
        we: in std_logic; -- Write enable
        write_addr: in unsigned(10 downto 0); -- Write address 1200 entries, 11 bits for address
        din: in std_logic_vector(7 downto 0); -- Data input (8 bits)

        -- Port B: read side
        read_addr: in unsigned(10 downto 0); -- Read address
        dout: out std_logic_vector(7 downto 0) -- Data output
    );
end entity text_ram;

architecture rtl of text_ram is
    type ram_t is array (0 to 1199) of std_logic_vector(7 downto 0); -- 1200 entries, each 8 bits
    signal ram: ram_t := (others => (others => '0')); -- Initialize RAM with zeros
begin

    -- Port A: Write process
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(write_addr)) <= din; -- Write data to RAM at specified address
            end if;
        end if;
    end process;

    -- Port B: Read process
    process(clk)
    begin
        if rising_edge(clk) then
            dout <= ram(to_integer(read_addr)); -- Read data from RAM at specified address
        end if;
    end process;

end architecture rtl;