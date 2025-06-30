library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
-- This ram is centered at 0x20000000 and has a size of 4KBytes (4096 words of 32 bits each).
-- the memory is byte adressable, but the address is word aligned.

entity ram is
    generic (
        ADDR_WIDTH : integer := 12 -- Width of address bus in ram
    );
    port (
        clk : in std_logic; -- Clock input
        rst : in std_logic; -- Reset input
        we : in std_logic; -- Write enable
        addr : in std_logic_vector(31 downto 0); -- Address input
        data_in : in std_logic_vector(31 downto 0); -- Data input
        data_out : out std_logic_vector(31 downto 0); -- Data output
        byte_enable : in std_logic_vector(3 downto 0) -- Byte enable (not used in this implementation)
    );
end ram;

architecture behavioral of ram is
    -- Define RAM type
    -- A 12-bit address bus means 2^12 = 4096 locations
    type ram_type is array ((2 ** ADDR_WIDTH) - 1 downto 0) of std_logic_vector(31 downto 0);
    signal ram_memory : ram_type;
    constant RAM_SIZE_BYTES : natural := (2 ** ADDR_WIDTH) * 4; -- Total amount of adressable memmory (bytes)
    constant HALF_RAM_SIZE_BYTES : natural := RAM_SIZE_BYTES / 2;

    constant RAM_BASE_ADDR : std_logic_vector(31 downto 0) := x"02000000";
    constant RAM_LOWER_BOUND : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(RAM_BASE_ADDR) - to_unsigned(HALF_RAM_SIZE_BYTES, 32));
    constant RAM_UPPER_BOUND : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(RAM_BASE_ADDR) + to_unsigned(HALF_RAM_SIZE_BYTES - 1, 32));

    attribute ram_style : string;
    attribute ram_style of ram_memory : signal is "block"; -- This attribute is used to

begin
    process (clk, rst, we, addr, data_in, byte_enable)
        variable mapped_addr_int : integer;
        variable temp_word_for_write : std_logic_vector(31 downto 0) := (others => '0');
    begin
        if falling_edge(clk) then
            if rst = '1' then
                -- Reset the RAM memory to zero
                for i in ram_memory'range loop
                    ram_memory(i) <= (others => '0');
                end loop;
                data_out <= (others => '0');
            else
                if unsigned(addr) >= unsigned(RAM_LOWER_BOUND) and unsigned(addr) <= unsigned(RAM_UPPER_BOUND) then
                    mapped_addr_int := to_integer(unsigned(addr) - unsigned(RAM_LOWER_BOUND)) / 4;
                    report "Mapped address: " & integer'image(mapped_addr_int);
                    if mapped_addr_int >= 0 and mapped_addr_int <= ram_memory'high then
                        if we = '1' then
                            report "Write operation at mapped address: " & integer'image(mapped_addr_int);
                            temp_word_for_write := ram_memory(mapped_addr_int);

                            if byte_enable = "1111" then -- SW (Store Word): All bytes are enabled.
                                temp_word_for_write := data_in;
                            elsif byte_enable = "0011" then -- SH (Store Halfword) at byte offset 0 (bits 0-15)
                                temp_word_for_write(15 downto 0) := data_in(15 downto 0);
                            elsif byte_enable = "1100" then -- SH (Store Halfword) at byte offset 2 (bits 16-31)
                                temp_word_for_write(31 downto 16) := data_in(15 downto 0);
                            elsif byte_enable(0) = '1' then -- SB (Store Byte) at byte offset 0 (bits 0-7)
                                temp_word_for_write(7 downto 0) := data_in(7 downto 0);
                            elsif byte_enable(1) = '1' then -- SB (Store Byte) at byte offset 1 (bits 8-15)
                                temp_word_for_write(15 downto 8) := data_in(7 downto 0);
                            elsif byte_enable(2) = '1' then -- SB (Store Byte) at byte offset 2 (bits 16-23)
                                temp_word_for_write(23 downto 16) := data_in(7 downto 0);
                            elsif byte_enable(3) = '1' then -- SB (Store Byte) at byte offset 3 (bits 24-31)
                                temp_word_for_write(31 downto 24) := data_in(7 downto 0);
                            end if;
                            ram_memory(mapped_addr_int) <= temp_word_for_write;
                        else
                            data_out <= ram_memory(mapped_addr_int);
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end behavioral;