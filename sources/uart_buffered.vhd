--uart_buffered.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart_buffered is
    generic (
        g_CLKS_PER_BIT : integer := 868;
        g_FIFO_DEPTH : natural := 16 -- Depth of the buffer
    );
    port (
        -- Global
        i_Clk : in std_logic;
        i_Rst : in std_logic;

        -- CPU Interface (Write to FIFO)
        i_CPU_TX_DV : in std_logic;
        i_CPU_TX_Byte : in std_logic_vector(7 downto 0);
        o_FIFO_Full : out std_logic;

        -- UART Serial Output
        o_TX_Serial : out std_logic
    );
end uart_buffered;

architecture Structural of uart_buffered is

    -- Signals to connect the FIFO to the UART
    signal s_fifo_data_out : std_logic_vector(7 downto 0);
    signal s_fifo_empty : std_logic;
    signal s_fifo_rd_en : std_logic;

    -- Signals from the UART
    signal s_uart_tx_active : std_logic;
    signal s_uart_tx_done : std_logic;

    -- Component declaration for the UART module (assumed to be in a separate file)
    component UART is
        generic (
            g_CLKS_PER_BIT : integer
        );
        port (
            i_Clk : in std_logic;
            i_TX_DV : in std_logic;
            i_TX_Byte : in std_logic_vector(7 downto 0);
            o_TX_Active : out std_logic;
            o_TX_Serial : out std_logic;
            o_TX_Done : out std_logic
        );
    end component;

    -- Component declaration for the FIFO buffer
    component fifo_buffer is
        generic (
            g_DATA_WIDTH : natural;
            g_DEPTH : natural
        );
        port (
            i_Clk : in std_logic;
            i_Rst : in std_logic;
            i_Wr_En : in std_logic;
            i_Wr_Data : in std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            o_Full : out std_logic;
            i_Rd_En : in std_logic;
            o_Rd_Data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            o_Empty : out std_logic
        );
    end component;
begin

    -- Instantiate the FIFO buffer
    FIFO_Inst : fifo_buffer
    generic map(
        g_DATA_WIDTH => 8,
        g_DEPTH => g_FIFO_DEPTH
    )
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst, -- You need to add a reset signal to your top level
        i_Wr_En => i_CPU_TX_DV,
        i_Wr_Data => i_CPU_TX_Byte,
        o_Full => o_FIFO_Full,
        i_Rd_En => s_fifo_rd_en,
        o_Rd_Data => s_fifo_data_out,
        o_Empty => s_fifo_empty
    );

    -- Instantiate the UART transmitter
    UART_Inst : uart
    generic map(
        g_CLKS_PER_BIT => g_CLKS_PER_BIT
    )
    port map(
        i_Clk => i_Clk,
        i_TX_DV => s_fifo_rd_en, -- UART's data valid comes from the FIFO read enable
        i_TX_Byte => s_fifo_data_out, -- UART's data comes from the FIFO
        o_TX_Active => s_uart_tx_active,
        o_TX_Serial => o_TX_Serial,
        o_TX_Done => s_uart_tx_done
    );

    -- Control logic to read from the FIFO
    -- The FIFO should be read when the UART is idle and the FIFO is not empty.
    -- The `o_TX_Done` signal from the UART is a perfect trigger to read the next byte.
    -- The `s_uart_tx_active` signal can also be used to indicate if a transmission is in progress.

    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                s_fifo_rd_en <= '0';
            else
                -- Check for the trigger condition
                -- r_fifo_rd_en will be asserted for one clock cycle if the condition is met.
                if s_uart_tx_done = '1' then
                    s_fifo_rd_en <= '1';
                    -- Trigger for the FIRST byte: UART is truly idle
                elsif s_uart_tx_active = '0' and s_fifo_rd_en = '0' then
                    s_fifo_rd_en <= '1';
                else
                    s_fifo_rd_en <= '0';
                end if;
            end if;
        end if;
    end process;

end Structural;