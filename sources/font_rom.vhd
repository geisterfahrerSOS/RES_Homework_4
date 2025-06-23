library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity font_rom is
    port (
        clk: in std_logic; -- Clock input
        char_code: in std_logic_vector(6 downto 0); -- Character code input (ASCII)
        font_row: in std_logic_vector(2 downto 0); -- Row index input (0 to 7)
        font_bits: out std_logic_vector(7 downto 0) -- Font line output (8 bits for each row of the character)
    );
end entity font_rom;

architecture behavioral of font_rom is
    type font_array is array (0 to 127, 0 to 7) of std_logic_vector(7 downto 0);
    signal font: font_array := (
        -- Character 0 (NULL)
        0 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 1 (Start of Heading)
        1 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 2 (Start of Text)
        2 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 3 (End of Text)
        3 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 4 (End of Transmission)
        4 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 5 (Enquiry)
        5 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 6 (Acknowledge)
        6 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 7 (Bell)
        7 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 8 (Backspace)
        8 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 9 (Horizontal Tab)
        9 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 10 (Line Feed)
        10 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 11 (Vertical Tab)
        11 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 12 (Form Feed)
        12 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 13 (Carriage Return)
        13 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 14 (Shift Out)
        14 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 15 (Shift In)
        15 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 16 (Data Link Escape)
        16 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 17 (Device Control 1)
        17 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 18 (Device Control 2)
        18 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 19 (Device Control 3)
        19 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 20 (Device Control 4)
        20 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 21 (Negative Acknowledge)
        21 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 22 (Synchronous Idle)
        22 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 23 (End of Transmission Block)
        23 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 24 (Cancel)
        24 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 25 (End of Medium)
        25 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 26 (Substitute)
        26 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 27 (Escape)
        27 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 28 (File Separator)
        28 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 29 (Group Separator)
        29 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 30 (Record Separator)
        30 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 31 (Unit Separator)
        31 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 32 (Space)
        32 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 33 (Exclamation Mark)
        33 => (x"3C", x"42", x"42", x"42", x"42", x"42", x"3C", x"00"),
        -- Character 34 (Double Quote)
        34 => (x"24", x"24", x"24", x"24", x"00", x"00", x"00", x"00"),
        -- Character 35 (Hash)
        35 => (x"3C", x"42", x"3C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 36 (Dollar Sign)
        36 => (x"18", x"24", x"3C", x"24", x"18", x"00", x"00", x"00"),
        -- Character 37 (Percent)
        37 => (x"3C", x"42", x"18", x"24", x"3C", x"00", x"00", x"00"),
        -- Character 38 (Ampersand)
        38 => (x"3C", x"42", x"3C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 39 (Single Quote)
        39 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- Character 40 (Left Parenthesis)
        40 => (x"18", x"24", x"42", x"42", x"24", x"18", x"00", x"00"),
        -- Character 41 (Right Parenthesis)
        41 => (x"18", x"24", x"42", x"42", x"24", x"18", x"00", x"00"),
        -- Character 42 (Asterisk)
        42 => (x"00", x"00", x"3C", x"00", x"00", x"00", x"00", x"00"),
        -- Character 43 (Plus)
        43 => (x"00", x"00", x"18", x"3C", x"18", x"00", x"00", x"00"),
        -- Character 44 (Comma)
        44 => (x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"00"),
        -- Character 45 (Hyphen)
        45 => (x"00", x"00", x"00", x"3C", x"00", x"00", x"00", x"00"),
        -- Character 46 (Period)
        46 => (x"00", x"00", x"00", x"00", x"18", x"00", x"00", x"00"),
        -- Character 47 (Slash)
        47 => (x"00", x"00", x"00", x"18", x"24", x"42", x"00", x"00"),
        -- Character 48 (Zero)
        48 => (x"3C", x"42", x"42", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 49 (One)
        49 => (x"18", x"38", x"18", x"18", x"3C", x"00", x"00", x"00"),
        -- Character 50 (Two)
        50 => (x"3C", x"42", x"0C", x"30", x"3C", x"00", x"00", x"00"),
        -- Character 51 (Three)
        51 => (x"3C", x"42", x"0C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 52 (Four)
        52 => (x"0C", x"1C", x"3C", x"42", x"7E", x"00", x"00", x"00"),
        -- Character 53 (Five)
        53 => (x"3E", x"40", x"3C", x"02", x"3C", x"00", x"00", x"00"),
        -- Character 54 (Six)
        54 => (x"3C", x"40", x"3C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 55 (Seven)
        55 => (x"3E", x"02", x"0C", x"30", x"30", x"00", x"00", x"00"),
        -- Character 56 (Eight)
        56 => (x"3C", x"42", x"3C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 57 (Nine)
        57 => (x"3C", x"42", x"3E", x"02", x"3C", x"00", x"00", x"00"),
        -- Character 58 (Colon)
        58 => (x"00", x"18", x"00", x"18", x"00", x"00", x"00", x"00"),
        -- Character 59 (Semicolon)
        59 => (x"00", x"18", x"00", x"18", x"00", x"00", x"18", x"00"),
        -- Character 60 (Less Than)
        60 => (x"00", x"00", x"18", x"24", x"42", x"00", x"00", x"00"),
        -- Character 61 (Equal)
        61 => (x"00", x"00", x"3C", x"00", x"3C", x"00", x"00", x"00"),
        -- Character 62 (Greater Than)
        62 => (x"00", x"00", x"42", x"24", x"18", x"00", x"00", x"00"),
        -- Character 63 (Question Mark)
        63 => (x"3C", x"42", x"0C", x"00", x"0C", x"00", x"00", x"00"),
        -- Character 64 (At Sign)
        64 => (x"3C", x"42", x"4A", x"52", x"3C", x"00", x"00", x"00"),
        -- Character 65 (A)
        65 => (x"3C", x"42", x"7E", x"42", x"42", x"00", x"00", x"00"),
        -- Character 66 (B)
        66 => (x"3C", x"42", x"7C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 67 (C)
        67 => (x"3C", x"42", x"40", x"40", x"3C", x"00", x"00", x"00"),
        -- Character 68 (D)
        68 => (x"3C", x"42", x"42", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 69 (E)
        69 => (x"7E", x"40", x"7C", x"40", x"7E", x"00", x"00", x"00"),
        -- Character 70 (F)
        70 => (x"7E", x"40", x"7C", x"40", x"40", x"00", x"00", x"00"),
        -- Character 71 (G)
        71 => (x"3C", x"42", x"40", x"4A", x"3E", x"00", x"00", x"00"),
        -- Character 72 (H)
        72 => (x"42", x"42", x"7E", x"42", x"42", x"00", x"00", x"00"),
        -- Character 73 (I)
        73 => (x"3C", x"18", x"18", x"18", x"3C", x"00", x"00", x"00"),
        -- Character 74 (J)
        74 => (x"0E", x"04", x"04", x"04", x"3C", x"00", x"00", x"00"),
        -- Character 75 (K)
        75 => (x"42", x"44", x"78", x"44", x"42", x"00", x"00", x"00"),
        -- Character 76 (L)
        76 => (x"40", x"40", x"40", x"40", x"7E", x"00", x"00", x"00"),
        -- Character 77 (M)
        77 => (x"42", x"66", x"7E", x"42", x"42", x"00", x"00", x"00"),
        -- Character 78 (N)
        78 => (x"42", x"62", x"7A", x"4A", x"42", x"00", x"00", x"00"),
        -- Character 79 (O)
        79 => (x"3C", x"42", x"42", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 80 (P)
        80 => (x"3C", x"42", x"7C", x"40", x"40", x"00", x"00", x"00"),
        -- Character 81 (Q)
        81 => (x"3C", x"42", x"42", x"4A", x"3C", x"00", x"00", x"00"),
        -- Character 82 (R)
        82 => (x"3C", x"42", x"7C", x"44", x"42", x"00", x"00", x"00"),
        -- Character 83 (S)
        83 => (x"3C", x"40", x"3C", x"02", x"3C", x"00", x"00", x"00"),
        -- Character 84 (T)
        84 => (x"7E", x"18", x"18", x"18", x"18", x"00", x"00", x"00"),
        -- Character 85 (U)
        85 => (x"42", x"42", x"42", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 86 (V)
        86 => (x"42", x"42", x"42", x"24", x"18", x"00", x"00", x"00"),
        -- Character 87 (W)
        87 => (x"42", x"42", x"42", x"66", x"3C", x"00", x"00", x"00"),
        -- Character 88 (X)
        88 => (x"42", x"24", x"18", x"24", x"42", x"00", x"00", x"00"),
        -- Character 89 (Y)
        89 => (x"42", x"42", x"24", x"18", x"18", x"00", x"00", x"00"),
        -- Character 90 (Z)
        90 => (x"7E", x"02", x"0C", x"30", x"7E", x"00", x"00", x"00"),
        -- Character 91 (Left Square Bracket)
        91 => (x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00"),
        -- Character 92 (Backslash)
        92 => (x"00", x"00", x"42", x"24", x"18", x"00", x"00", x"00"),
        -- Character 93 (Right Square Bracket)
        93 => (x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00"),
        -- Character 94 (Caret)
        94 => (x"00", x"18", x"24", x"00", x"00", x"00", x"00", x"00"),
        -- Character 95 (Underscore)
        95 => (x"00", x"00", x"00", x"00", x"00", x"00", x"3C", x"00"),
        -- Character 96 (Grave Accent)
        96 => (x"00", x"00", x"00", x"18", x"24", x"00", x"00", x"00"),
        -- Character 97 (a)
        97 => (x"00", x"00", x"3C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 98 (b)
        98 => (x"40", x"40", x"7C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 99 (c)
        99 => (x"00", x"00", x"3C", x"40", x"3C", x"00", x"00", x"00"),
        -- Character 100 (d)
        100 => (x"02", x"02", x"3E", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 101 (e)
        101 => (x"00", x"00", x"3C", x"40", x"3C", x"00", x"00", x"00"),
        -- Character 102 (f)
        102 => (x"18", x"24", x"7C", x"24", x"24", x"00", x"00", x"00"),
        -- Character 103 (g)
        103 => (x"00", x"00", x"3C", x"42", x"3E", x"02", x"3C", x"00"),
        -- Character 104 (h)
        104 => (x"40", x"40", x"7C", x"42", x"42", x"00", x"00", x"00"),
        -- Character 105 (i)
        105 => (x"18", x"00", x"18", x"18", x"3C", x"00", x"00", x"00"),
        -- Character 106 (j)
        106 => (x"04", x"00", x"04", x"04", x"3C", x"00", x"00", x"00"),
        -- Character 107 (k)
        107 => (x"40", x"44", x"78", x"44", x"42", x"00", x"00", x"00"),
        -- Character 108 (l)
        108 => (x"18", x"18", x"18", x"18", x"3C", x"00", x"00", x"00"),
        -- Character 109 (m)
        109 => (x"00", x"00", x"7E", x"42", x"42", x"00", x"00", x"00"),
        -- Character 110 (n)
        110 => (x"00", x"00", x"7C", x"42", x"42", x"00", x"00", x"00"),
        -- Character 111 (o)
        111 => (x"00", x"00", x"3C", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 112 (p)
        112 => (x"00", x"00", x"7C", x"42", x"3C", x"40", x"40", x"00"),
        -- Character 113 (q)
        113 => (x"00", x"00", x"3E", x"42", x"3C", x"02", x"02", x"00"),
        -- Character 114 (r)
        114 => (x"00", x"00", x"7C", x"44", x"40", x"00", x"00", x"00"),
        -- Character 115 (s)
        115 => (x"00", x"00", x"3C", x"02", x"3C", x"00", x"00", x"00"),
        -- Character 116 (t)
        116 => (x"18", x"18", x"7C", x"18", x"18", x"00", x"00", x"00"),
        -- Character 117 (u)
        117 => (x"00", x"00", x"42", x"42", x"3C", x"00", x"00", x"00"),
        -- Character 118 (v)
        118 => (x"00", x"00", x"42", x"42", x"24", x"18", x"00", x"00"),
        -- Character 119 (w)
        119 => (x"00", x"00", x"42", x"66", x"3C", x"00", x"00", x"00"),
        -- Character 120 (x)
        120 => (x"00", x"00", x"42", x"24", x"42", x"00", x"00", x"00"),
        -- Character 121 (y)
        121 => (x"00", x"00", x"42", x"42", x"3E", x"02", x"3C", x"00"),
        -- Character 122 (z)
        122 => (x"00", x"00", x"7E", x"0C", x"7E", x"00", x"00", x"00"),
        -- Character 123 (Left Brace)
        123 => (x"18", x"24", x"24", x"18", x"24", x"24", x"18", x"00"),
        -- Character 124 (Vertical Bar)
        124 => (x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"00"),
        -- Character 125 (Right Brace)
        125 => (x"18", x"24", x"24", x"18", x"24", x"24", x"18", x"00"),
        -- Character 126 (Tilde)
        126 => (x"00", x"00", x"00", x"18", x"24", x"00", x"00", x"00"),
        -- Character 127 (Delete)
        127 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
        -- add all of the other ascii characters here

        others => (others => x"00") -- Default to 0 for all other characters
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Output the font line based on character code and row index
            font_bits <= font(to_integer(unsigned(char_code)), to_integer(unsigned(font_row)));
        end if;
    end process;
end architecture behavioral;

