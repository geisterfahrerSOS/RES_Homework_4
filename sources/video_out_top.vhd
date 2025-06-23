library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity video_out_top is
    port(
        clk100Mhz: in std_logic; -- 100 MHz clock input
        reset: in std_logic; -- Reset signal

        --VGA output signals
        vga_red: out std_logic_vector(3 downto 0); -- VGA Red signal
        vga_green: out std_logic_vector(3 downto 0); -- VGA Green signal
        vga_blue: out std_logic_vector(3 downto 0); -- VGA Blue signal
        vga_hsync: out std_logic; -- VGA Horizontal Sync signal
        vga_vsync: out std_logic; -- VGA Vertical Sync signal
    );
end entity video_out_top;

architecture rtl of video_out_top is

    -- Clock divider for 25 MHz clock
    signal clk25Mhz: std_logic := '0'; -- 25 MHz clock signal
    signal clk_divider: unsigned(1 downto 0) := (others => '0'); -- Clock divider counter

    --Signals
    signal char_addr: unsigned(10 downto 0) := (others => '0'); -- Character address for text RAM
    signal char_data: std_logic_vector(7 downto 0); -- Character data from text RAM
    signal font_row: unsigned(2 downto 0); -- Row in font ROM
    signal font_bits: std_logic_vector(7 downto 0); -- Font bits for the character

    --RAM interface
    signal we: std_logic := '0'; -- Write enable signal for text RAM
    signal write_addr: unsigned(10 downto 0) := (others => '0'); -- Write address for text RAM
    signal din: std_logic_vector(7 downto 0) := (others => '0'); -- Data input for text RAM

begin
    -- Clock divider (100-> 25)
    process(clk100Mhz)
    begin
        if rising_edge(clk100Mhz) then
            clk_divider <= clk_divider + 1;
            clk25Mhz <= clk_divider(1); -- Toggle clk25Mhz every 4 clock cycles of clk100Mhz
        end if;
    end process;

    -- VGA text generator instance
    vga_text_inst: entity work.vga_text
        port map (
            clk => clk25Mhz,
            reset => reset,
            red => vga_red,
            green => vga_green,
            blue => vga_blue,
            h_sync => vga_hsync,
            v_sync => vga_vsync,
            char_addr => char_addr, -- Character address in text RAM
            char_data => char_data, -- Character data from text RAM
            font_char => char_data, -- Character code from text RAM
            font_row => font_row, -- Row in font ROM
            font_bits => font_bits -- Font bits for the character
        );
    
    -- Text RAM instance
    text_ram_inst: entity work.text_ram
        port map (
            clk => clk25Mhz,
            we => we, -- Write enable signal
            write_addr => write_addr, -- Write address
            din => din, -- Data input
            read_addr => char_addr, -- Read address (same as char_addr for simplicity)
            dout => char_data -- Data output (character data)
        );
    
    -- Font ROM instance
    font_rom_inst: entity work.font_rom
        port map (
            clk => clk25Mhz,
            char_code => char_data, -- Character code from text RAM
            row => font_row, -- Row in font ROM
            bits => font_bits -- Font bits for the character
        );
    
    process(clk25Mhz)
    begin
        if rising_edge(clk25Mhz) then
            -- might need work
            if reset = '1' then
                we <= '1'; -- Reset write enable
                write_addr <= to_unsigned(0,11); -- Reset write address
                din <= x"48"; -- Reset data input, H
            
            elsif write_addr = to_unsigned(4,11) then
                we <= '0'; -- Disable write enable after writing
            else
                write_addr <= write_addr + 1; -- Increment write address
                case to_integer(write_addr) is
                    when 0 => din <= x"48"; -- 'H'
                    when 1 => din <= x"65"; -- 'A'
                    when 2 => din <= x"76"; -- 'L'
                    when 3 => din <= x"4C"; -- 'L'
                    when 4 => din <= x"4F"; -- 'O'
                    when others => din <= x"20"; -- Default case
                end case;
            end if;
        end if;
    end process;

end architecture rtl;