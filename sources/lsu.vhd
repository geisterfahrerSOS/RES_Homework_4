library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.opcodes.all; -- Import opcode definitions

entity lsu is
    port (
        clk : in std_logic;
        rst : in std_logic;
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        addr : in std_logic_vector(31 downto 0);
        data_reg_in : in std_logic_vector(31 downto 0);
        data_mem_in : in std_logic_vector(31 downto 0); -- Data from RAM/main memory to LSU
        data_reg_out : out std_logic_vector(31 downto 0);
        data_mem_out : out std_logic_vector(31 downto 0); -- Data from LSU to RAM/main memory
        rom_data_in : in std_logic_vector(31 downto 0); -- Input data from ROM (for load operations)
        byte_enable : out std_logic_vector(3 downto 0); -- Byte enable for store operations
        mem_we : out std_logic; -- Write enable signal for store operations

        uart_rx_data_in : in std_logic_vector(7 downto 0);-- Received byte from UART
        uart_rx_valid_in : in std_logic;-- UART RX data is valid
        uart_tx_full_in : in std_logic;-- UART TX buffer is full

        uart_tx_data_out : out std_logic_vector(7 downto 0); -- Byte to transmit via UART
        uart_tx_strobe_out : out std_logic;-- Strobe to tell UART to transmit
        uart_baudrate_out : out std_logic_vector(31 downto 0); -- Baud rate divisor to UART
        uart_baudrate_we_out : out std_logic -- Write enable for UART clkdiv register
    );
end lsu;

architecture Behavioral of lsu is
    constant ROM_MEMORY_END : std_logic_vector(31 downto 0) := x"00001FFF"; -- Example: ROM from 0x0000_0000 to 0x0000_1FFF (8KB)
    constant RAM_START_ADDR : std_logic_vector(31 downto 0) := x"01FFCFFF"; -- Example: RAM starts at 0x0200_0000
    constant RAM_END_ADDR : std_logic_vector(31 downto 0) := x"02000000"; -- Example: 4KB RAM ends at 0x0200_0FFF

    -- UART MMIO Addresses
    constant UART_STATUS_ADDR : std_logic_vector(31 downto 0) := x"02000000";
    constant UART_BAUDRATE_ADDR : std_logic_vector(31 downto 0) := x"02000004";
    constant UART_DATA_ADDR : std_logic_vector(31 downto 0) := x"02000008";
begin
    process (opcode, funct3, addr, data_reg_in, data_mem_in, rom_data_in,
        uart_rx_data_in, uart_rx_valid_in, uart_tx_full_in, rst)
        variable internal_read_data : std_logic_vector(31 downto 0);
        variable is_ram_access : std_logic;
        variable is_rom_access : std_logic; -- For data loads from ROM region
        variable is_uart_access : std_logic;
        variable uart_read_data : std_logic_vector(31 downto 0);
    begin
        -- Default outputs (combinatorial reset)
        data_reg_out <= (others => '0');
        data_mem_out <= (others => '0');
        byte_enable <= (others => '0');
        mem_we <= '0';
        uart_tx_data_out <= (others => '0');
        uart_tx_strobe_out <= '0';
        uart_baudrate_out <= (others => '0');
        uart_baudrate_we_out <= '0';

        -- Determine memory region being accessed
        is_rom_access := '0';
        is_ram_access := '0';
        is_uart_access := '0';

        -- Address Decoding Logic
        if unsigned(addr) < unsigned(ROM_MEMORY_END) then
            is_rom_access := '1'; -- This is for data loads from ROM, if your ROM holds data like string literals
        elsif unsigned(addr) >= unsigned(RAM_START_ADDR) and unsigned(addr) <= unsigned(RAM_END_ADDR) then
            is_ram_access := '1';
        elsif addr = UART_STATUS_ADDR or addr = UART_BAUDRATE_ADDR or addr = UART_DATA_ADDR then
            is_uart_access := '1';
        end if;

        if rst = '1' then
            -- Default outputs are already handled by the initial assignments
            null;
        else
            if opcode = OPCODE_LOAD then -- Load instructions
                -- First, get the raw word data from the appropriate memory/peripheral
                if is_rom_access = '1' then
                    internal_read_data := rom_data_in;
                elsif is_ram_access = '1' then
                    internal_read_data := data_mem_in; -- Use RAM data for load operations
                elsif is_uart_access = '1' then
                    -- Logic for reading from UART registers
                    case addr is
                        when UART_DATA_ADDR =>
                            -- When reading UART_DATA_ADDR, return the received byte.
                            -- Ensure uart_rx_data_in is properly connected (8 bits).
                            uart_read_data := (others => '0');
                            uart_read_data(7 downto 0) := uart_rx_data_in;
                            internal_read_data := uart_read_data;
                        when UART_STATUS_ADDR =>
                            -- Assemble status bits into a word
                            uart_read_data := (others => '0');
                            uart_read_data(0) := uart_rx_valid_in; -- Example: bit 0 for RX_VALID
                            uart_read_data(1) := not uart_tx_full_in; -- Example: bit 1 for TX_READY (not full)
                            internal_read_data := uart_read_data;
                        when UART_BAUDRATE_ADDR =>
                            -- Assuming uart_clkdiv_out (from a previous write) could be read back
                            -- For simplicity, if not stored, return 0 or default.
                            -- If your UART module has a clkdiv_out port that reflects the *current* setting, use that.
                            internal_read_data := (others => '0'); -- Placeholder if not directly readable
                        when others =>
                            internal_read_data := (others => '0'); -- Unmapped UART address read
                    end case;
                else
                    internal_read_data := (others => '0'); -- Access to unmapped memory region
                end if;

                -- Now, process the loaded 'internal_read_data' based on funct3 for sign/zero extension and byte/halfword selection
                case funct3 is
                    when "000" => -- LB (Load Byte, sign-extended)
                        case addr(1 downto 0) is
                            when "00" => data_reg_out <= std_logic_vector(resize(signed(internal_read_data(7 downto 0)), 32));
                            when "01" => data_reg_out <= std_logic_vector(resize(signed(internal_read_data(15 downto 8)), 32));
                            when "10" => data_reg_out <= std_logic_vector(resize(signed(internal_read_data(23 downto 16)), 32));
                            when "11" => data_reg_out <= std_logic_vector(resize(signed(internal_read_data(31 downto 24)), 32));
                            when others => data_reg_out <= (others => '0');
                        end case;
                    when "001" => -- LH (Load Halfword, sign-extended)
                        if addr(1) = '0' then
                            data_reg_out <= std_logic_vector(resize(signed(internal_read_data(15 downto 0)), 32));
                        else
                            data_reg_out <= std_logic_vector(resize(signed(internal_read_data(31 downto 16)), 32));
                        end if;
                    when "010" => -- LW (Load Word)
                        data_reg_out <= internal_read_data;
                    when "100" => -- LBU (Load Byte, zero-extended)
                        case addr(1 downto 0) is
                            when "00" => data_reg_out <= (31 downto 8 => '0') & internal_read_data(7 downto 0);
                            when "01" => data_reg_out <= (31 downto 8 => '0') & internal_read_data(15 downto 8);
                            when "10" => data_reg_out <= (31 downto 8 => '0') & internal_read_data(23 downto 16);
                            when "11" => data_reg_out <= (31 downto 8 => '0') & internal_read_data(31 downto 24);
                            when others => data_reg_out <= (others => '0');
                        end case;
                    when "101" => -- LHU (Load Halfword, zero-extended)
                        if addr(1) = '0' then
                            data_reg_out <= (31 downto 16 => '0') & internal_read_data(15 downto 0);
                        else
                            data_reg_out <= (31 downto 16 => '0') & internal_read_data(31 downto 16);
                        end if;
                    when others =>
                        data_reg_out <= (others => '0');
                end case;

            elsif opcode = OPCODE_STORE then -- Store instructions
                if is_ram_access = '1' then
                    mem_we <= '1';
                    data_mem_out <= data_reg_in; -- Output data to RAM
                    case funct3 is
                        when "000" => -- SB (Store Byte)
                            case addr(1 downto 0) is
                                when "00" => byte_enable <= "0001"; -- Enable byte 0
                                when "01" => byte_enable <= "0010"; -- Enable byte 1
                                when "10" => byte_enable <= "0100"; -- Enable byte 2
                                when "11" => byte_enable <= "1000"; -- Enable byte 3
                                when others => byte_enable <= (others => '0'); -- Invalid address
                            end case;
                        when "001" => -- SH (Store Halfword)
                            if addr(1) = '0' then
                                byte_enable <= "0011"; -- Enable bytes 0 and 1
                            else
                                byte_enable <= "1100"; -- Enable bytes 2 and 3
                            end if;
                        when "010" => -- SW (Store Word)
                            byte_enable <= "1111"; -- All bytes enabled for word store
                        when others =>
                            byte_enable <= (others => '0'); -- Invalid func3
                            mem_we <= '0'; -- Clear write enable for invalid operations
                    end case;
                elsif is_uart_access = '1' then
                    case addr is
                        when UART_DATA_ADDR =>
                            -- Store the LSB of data_reg_in to UART TX data
                            uart_tx_data_out <= data_reg_in(7 downto 0);
                            uart_tx_strobe_out <= '1'; -- Strobe UART to transmit
                        when UART_BAUDRATE_ADDR =>
                            -- Store the full word to UART Clock Divisor
                            uart_baudrate_out <= data_reg_in;
                            uart_baudrate_we_out <= '1'; -- Assert write enable for clkdiv register
                        when others =>
                            -- Attempted write to unmapped UART address
                            null;
                    end case;
                else
                    -- Attempted store to unmapped memory region
                end if;
            else
                -- Not a load or store instruction, ensure outputs are default
                null;
            end if;
        end if;
    end process;
end Behavioral;