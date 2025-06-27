-- fifo_buffer.vhd
-- A simple synchronous FIFO buffer for a UART transmitter.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_buffer is
    generic (
        g_DATA_WIDTH : natural := 8;  -- Data bus width (e.g., 8 for a byte)
        g_DEPTH      : natural := 16  -- Number of entries in the FIFO
    );
    port (
        -- Clock and Reset
        i_Clk   : in  std_logic;
        i_Rst   : in  std_logic;

        -- Write Interface (from CPU)
        i_Wr_En   : in  std_logic;
        i_Wr_Data : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
        o_Full    : out std_logic;

        -- Read Interface (to UART)
        i_Rd_En   : in  std_logic;
        o_Rd_Data : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
        o_Empty   : out std_logic
    );
end fifo_buffer;

architecture RTL of fifo_buffer is

    -- FIFO Memory
    type t_fifo_mem is array (0 to g_DEPTH-1) of std_logic_vector(g_DATA_WIDTH-1 downto 0);
    signal r_fifo_mem : t_fifo_mem := (others => (others => '0'));

    -- Pointers
    signal r_wr_ptr : natural range 0 to g_DEPTH-1 := 0;
    signal r_rd_ptr : natural range 0 to g_DEPTH-1 := 0;

    -- Counter for full/empty logic
    signal r_count : natural range 0 to g_DEPTH := 0;

begin

    p_fifo_logic : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                r_wr_ptr <= 0;
                r_rd_ptr <= 0;
                r_count  <= 0;
            else
                -- Write operation
                if i_Wr_En = '1' and r_count < g_DEPTH then
                    r_fifo_mem(r_wr_ptr) <= i_Wr_Data;
                    r_wr_ptr <= (r_wr_ptr + 1) mod g_DEPTH;
                    r_count  <= r_count + 1;
                end if;

                -- Read operation
                if i_Rd_En = '1' and r_count > 0 then
                    r_rd_ptr <= (r_rd_ptr + 1) mod g_DEPTH;
                    r_count  <= r_count - 1;
                end if;
            end if;
        end if;
    end process p_fifo_logic;

    -- Read data output
    o_Rd_Data <= r_fifo_mem(r_rd_ptr);

    -- Full and Empty flags
    o_Full  <= '1' when r_count = g_DEPTH else '0';
    o_Empty <= '1' when r_count = 0       else '0';

end RTL;