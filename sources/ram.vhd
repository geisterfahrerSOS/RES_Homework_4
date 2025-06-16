library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    generic (
        DATA_WIDTH : integer := 32;    -- Width of data bus
        ADDR_WIDTH : integer := 10     -- Width of address bus
    );
    port (
        clk     : in  std_logic;                                     -- Clock input
        we      : in  std_logic;                                     -- Write enable
        addr    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);      -- Address input
        data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);      -- Data input
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0)       -- Data output
    );
end ram;

architecture behavioral of ram is
    -- Define RAM type
    type ram_type is array ((2**ADDR_WIDTH)-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram_memory : ram_type;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram_memory(to_integer(unsigned(addr))) <= data_in;
            end if;
            data_out <= ram_memory(to_integer(unsigned(addr)));
        end if;
    end process;
end behavioral;