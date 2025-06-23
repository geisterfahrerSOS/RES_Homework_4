library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_text is
    port (
        clk: in std_logic;
        reset: in std_logic;

        -- VGA outputs
        red: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0);
        h_sync: out std_logic;
        v_sync: out std_logic;

        -- Connection to text RAM
        char_addr: out unsigned(10 downto 0); -- Character address in text RAM
        char_data: in std_logic_vector(7 downto 0); -- Character data

        -- Connection to font ROM
        font_char: in std_logic_vector(7 downto 0); -- Character code from text RAM
        font_row: out unsigned(2 downto 0); -- Row in font ROM
        font_bits: in std_logic_vector(7 downto 0); -- Font bits for the character
    );
end entity vga_text;

architecture rtl of vga_text is

    -- VGA timing for 640x480 @ 60Hz
    constant H_VISIBLE: integer := 640; -- Horizontal visible area
    constant H_FRONT_PORCH: integer := 16; -- Horizontal front porch
    constant H_SYNC_PULSE: integer := 96; -- Horizontal sync pulse width
    constant H_BACK_PORCH: integer := 48; -- Horizontal back porch
    constant H_TOTAL: integer := H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; -- Total horizontal pixels

    constant V_VISIBLE: integer := 480; -- Vertical visible area
    constant V_FRONT_PORCH: integer := 10; -- Vertical front porch
    constant V_SYNC_PULSE: integer := 2; -- Vertical sync pulse width
    constant V_BACK_PORCH: integer := 33; -- Vertical back porch
    constant V_TOTAL: integer := V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; -- Total vertical lines

    -- internal counters
    signal h_count: integer range 0 to H_TOTAL - 1 := 0; -- Horizontal pixel counter
    signal v_count: integer range 0 to V_TOTAL - 1 := 0;

    signal visible_area: std_logic; -- Signal to indicate if we are in the visible area
    signal pixel_x: integer range 0 to H_VISIBLE - 1 := 0; -- Pixel X position in visible area
    signal pixel_y: integer range 0 to V_VISIBLE - 1 := 0;

    signal char_col, char_row: integer range 0 to 39;
    signal row_within_char: integer range  0 to 7; -- Row within the character (0-7 for 8 rows in a character)

    signal font_row_bits: std_logic_vector(7 downto 0); -- Bits for the current row of the character

begin

    --VGA counters
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                h_count <= 0;
                v_count <= 0;
            else
                if h_count = H_TOTAL - 1 then
                    h_count <= 0;
                    if v_count = V_TOTAL - 1 then
                        v_count <= 0;
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- sync signals
    h_sync <= '0' when (h_count >= H_VISIBLE + H_FRONT_PORCH and h_count < H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE) else '1';
    v_sync <= '0' when (v_count >= V_VISIBLE + V_FRONT_PORCH and v_count < V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE) else '1';

    -- Only render top left 320x240 area
    visible_area <= '1' when h_count < 320 and v_count < 240 else '0';
    pixel_x <= h_count;
    pixel_y <= v_count;

    -- character grid lookup
    char_col <= pixel_x / 8; -- 8 pixels per character column
    char_row <= pixel_y / 8; -- 8 pixels per character row
    row_within_char <= pixel_y mod 8; -- Row within the character

    char_addr <= to_unsigned(char_row * 40 + char_col, 11);

    font_char <= char_data; -- Get character code from text RAM
    font_row <= to_unsigned(row_within_char, 3); -- Row in font ROM
    font_row_bits <= font_bits; -- Get bits for the current row of the character

    -- pixel color output

    process(clk)
    variable bit_index: integer; -- Index for the current bit in the character
    begin
        if rising_edge(clk) then
            if visible_area = '1' then
                bit_index := 7- (pixel_x mod 8); -- Get the bit index for the current pixel in the character
                if font_row_bits(bit_index) = '1' then
                    red <= "1111"; -- Set color to white (or any color you prefer)
                    green <= "1111";
                    blue <= "1111";
                else
                    red <= "0000"; -- Set color to black (or background color)
                    green <= "0000";
                    blue <= "0000";
                end if;
            else
                red <= (others => '0'); -- Set color to black (or background color)
                green <= (others => '0');
                blue <= (others => '0');
            end if;
        end if;
    end process;

end architecture rtl;
