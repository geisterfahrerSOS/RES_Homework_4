-- filepath: c:\Users\marco\Documents\GitHub\RES_Homework_4\sources\riscv_top.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity riscv_top is
    port (
        clk : in std_logic;
        rst : in std_logic;
        -- uart_rx : in std_logic; -- UART receive input
        uart_tx : out std_logic -- UART transmit output
    );
end riscv_top;

architecture Behavioral of riscv_top is
    -- Component declarations for the RISC-V processor
    component control_unit is
        port (
            rst : in std_logic;
            opcode : in std_logic_vector(6 downto 0); -- Opcode output
            rd : in std_logic_vector(4 downto 0); -- Destination register output
            funct3 : in std_logic_vector(2 downto 0); -- Function3 output
            rs1 : in std_logic_vector(4 downto 0); -- Source register 1 output
            rs2 : in std_logic_vector(4 downto 0); -- Source register 2 output
            funct7 : in std_logic_vector(6 downto 0); -- Function7 output
            src_a_sel : out std_logic;
            src_b_sel : out std_logic;
            rd_we : out std_logic; -- Write enable for destination register
            alu_op : out std_logic_vector(3 downto 0); -- ALU operation code output
            wb_sel : out std_logic_vector(1 downto 0); -- Write-back select output -- maybe not needed due to opcode info
            pc_sel : out std_logic_vector(2 downto 0) -- PC select output
        );
    end component;

    -- Signals for program counter and branching
    component mux_pc is
        port (
            clk : in std_logic;
            reset : in std_logic;
            pc_sel : in std_logic_vector(2 downto 0);
            branch_cond : in std_logic;
            imm : in std_logic_vector(31 downto 0);
            rs1_data : in std_logic_vector(31 downto 0);
            pc_out : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Component declarations
    component alu is
        port (
            src_a : in std_logic_vector(31 downto 0);
            src_b : in std_logic_vector(31 downto 0);
            alu_op : in std_logic_vector(3 downto 0);
            alU_result : out std_logic_vector(31 downto 0);
            alu_flags : out std_logic_vector(3 downto 0)
        );
    end component;

    component branch_logic is
        port (
            rs1_data : in std_logic_vector(31 downto 0);
            rs2_data : in std_logic_vector(31 downto 0);
            branch_sel : in std_logic_vector(2 downto 0);
            branch_cond : out std_logic
        );
    end component;

    component decoder is
        port (
            instr : in std_logic_vector(31 downto 0);
            opcode : out std_logic_vector(6 downto 0);
            rd : out std_logic_vector(4 downto 0);
            funct3 : out std_logic_vector(2 downto 0);
            rs1 : out std_logic_vector(4 downto 0);
            rs2 : out std_logic_vector(4 downto 0);
            funct7 : out std_logic_vector(6 downto 0)
        );
    end component;

    component imm_generator is
        port (
            instr : in std_logic_vector(31 downto 0);
            imm : out std_logic_vector(31 downto 0)
        );
    end component;

    component rom is
        generic (
            addr_width : integer := 10;
            data_width : integer := 32
        );
        port (
            addr : in std_logic_vector(addr_width - 1 downto 0);
            data : out std_logic_vector(data_width - 1 downto 0)
        );
    end component;

    component ram is
        generic (
            ADDR_WIDTH : integer := 12 -- Width of address bus
        );
        port (
            clk : in std_logic; -- Clock input
            rst : in std_logic; -- Reset input
            we : in std_logic; -- Write enable
            addr : in std_logic_vector(31 downto 0); -- Address input
            data_in : in std_logic_vector(31 downto 0); -- Data input
            data_out : out std_logic_vector(31 downto 0); -- Data output
            byte_enable : in std_logic_vector(3 downto 0) -- Byte enable
        );
    end component;

    component mux_alu_src_a is
        port (
            rs1_data : in std_logic_vector(31 downto 0); -- Data from register rs1
            pc : in std_logic_vector(31 downto 0); -- PC
            src_a_sel : in std_logic;
            src_a : out std_logic_vector(31 downto 0) -- mux output
        );
    end component;

    component mux_alu_src_b is
        port (
            rs2_data : in std_logic_vector(31 downto 0); -- Data from register rd2
            imm : in std_logic_vector(31 downto 0); -- Immediate value
            src_b_sel : in std_logic;
            src_b : out std_logic_vector(31 downto 0) -- mux output
        );
    end component;

    component mux_wb is
        port (
            alu_result : in std_logic_vector(31 downto 0);
            pc_plus_4 : in std_logic_vector(31 downto 0);
            imm : in std_logic_vector(31 downto 0);
            wb_sel : in std_logic_vector(1 downto 0);
            wb_data : out std_logic_vector(31 downto 0);
            wb_lsu_data : in std_logic_vector(31 downto 0) -- Memory data input
        );
    end component;

    component register_file is
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
    end component;

    component lsu is
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
    end component;

    component uart is
        generic (
            g_CLKS_PER_BIT : integer := 868 -- Needs to be set correctly, 115200 baud rate means 868 clock cycles per bit at 100 MHz clock frequency
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

    -- Signals for decoder outputs
    signal pc : std_logic_vector(31 downto 0);
    signal instr : std_logic_vector(31 downto 0);

    signal opcode : std_logic_vector(6 downto 0);
    signal rd : std_logic_vector(4 downto 0);
    signal rs1 : std_logic_vector(4 downto 0);
    signal rs2 : std_logic_vector(4 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

    signal imm : std_logic_vector(31 downto 0);

    signal rs1_data : std_logic_vector(31 downto 0);
    signal rs2_data : std_logic_vector(31 downto 0);

    signal src_a : std_logic_vector(31 downto 0);
    signal src_b : std_logic_vector(31 downto 0);

    signal alu_result : std_logic_vector(31 downto 0);
    signal alu_flags : std_logic_vector(3 downto 0);

    signal alu_op : std_logic_vector(3 downto 0);
    signal wb_sel : std_logic_vector(1 downto 0);
    signal rd_we : std_logic;
    signal pc_sel : std_logic_vector(2 downto 0);
    signal src_a_sel : std_logic;
    signal src_b_sel : std_logic;

    signal mem_we : std_logic;

    signal branch_cond : std_logic;

    signal wb_data : std_logic_vector(31 downto 0); -- Data to be written back to the register file could be ALU result, pc+4, immediate value, or memory data

    -- Signals for LSU
    signal byte_enable : std_logic_vector(3 downto 0); -- Byte enable for memory operations
    signal data_reg_out : std_logic_vector(31 downto 0); -- Data output from lsu to register file
    -- signal data_reg_in : std_logic_vector(31 downto 0); -- Data input to lsu from register file
    signal data_mem_in : std_logic_vector(31 downto 0); -- Data input to lsu from RAM
    signal data_mem_out : std_logic_vector(31 downto 0); -- Data output from lsu to RAM

    signal rom_data : std_logic_vector(31 downto 0); -- Data read from ROM

    signal uart_rx_data : std_logic_vector(7 downto 0); -- Received byte from UART
    signal uart_tx_data : std_logic_vector(7 downto 0); -- Byte to transmit via UART
    signal uart_tx_en : std_logic; -- UART transmit enable signal
begin
    -- Instantiate the control unit
    control_unit_inst : control_unit
    port map(
        rst => rst,
        opcode => opcode,
        rd => rd,
        funct3 => funct3,
        rs1 => rs1,
        rs2 => rs2,
        funct7 => funct7,
        src_a_sel => src_a_sel,
        src_b_sel => src_b_sel,
        rd_we => rd_we,
        alu_op => alu_op,
        wb_sel => wb_sel,
        pc_sel => pc_sel
    );

    -- Instantiate the program counter
    mux_pc_inst : mux_pc
    port map(
        clk => clk,
        reset => rst,
        pc_sel => pc_sel,
        branch_cond => branch_cond,
        imm => imm,
        rs1_data => rs1_data,
        pc_out => pc
    );
    -- Instantiate UART for communication
    uart_inst : uart
    generic map(
        g_CLKS_PER_BIT => 868 -- 100 MHz clock / 115200 baud = 868.055 ? 868
    )
    port map(
        i_Clk => clk,
        i_TX_DV => uart_tx_en,
        i_TX_Byte => uart_tx_data, -- Transmit the lower byte of the write-back data
        o_TX_Active => open, -- Not used in this context
        o_TX_Serial => uart_tx, -- UART transmit output
        o_TX_Done => open -- Not used in this context
    );
    -- Instantiate ROM for instruction memory
    rom_inst : rom
    generic map(
        addr_width => 10,
        data_width => 32
    )
    port map(
        addr => pc(9 downto 0), -- Assuming pc is at least 10 bits wide
        data => instr -- You'll need to declare this signal
    );

    rom_inst_data : rom
    generic map(
        addr_width => 10,
        data_width => 32
    )
    port map(
        addr => alu_result(9 downto 0), -- Assuming alu_result is at least 10 bits wide
        data => rom_data -- Data read from ROM for data memory operations
    );

    -- Instantiate RAM for data memory
    ram_inst : ram
    generic map(
        ADDR_WIDTH => 12 -- Width of address bus
    )
    port map(
        clk => clk,
        rst => rst,
        we => mem_we, -- Write enable signal
        addr => alu_result, -- Address for RAM access, typically the ALU result
        data_in => data_mem_out, -- Data to write into RAM
        data_out => data_mem_in, -- Data read from RAM
        byte_enable => byte_enable -- Byte enable for memory operations
    );

    lsu_inst : lsu
    port map(
        clk => clk,
        rst => rst,
        opcode => opcode,
        funct3 => funct3,
        addr => alu_result,
        data_reg_in => rs2_data,
        data_mem_out => data_mem_out,
        data_mem_in => data_mem_in,
        data_reg_out => data_reg_out,
        rom_data_in => rom_data, -- Data read from ROM for load operations
        byte_enable => byte_enable,
        mem_we => mem_we,
        uart_rx_data_in => uart_rx_data, -- Received byte from UART
        uart_rx_valid_in => '0', -- Assuming no UART RX data valid signal in this
        uart_tx_full_in => '0', -- Assuming UART TX buffer is not full
        uart_tx_data_out => uart_tx_data, -- Byte to
        uart_tx_strobe_out => uart_tx_en, -- Strobe to tell UART to transmit
        uart_baudrate_out => open, -- Baud rate divisor to UART (
        uart_baudrate_we_out => open -- Write enable for UART clkdiv register
    );

    -- Instance decoder and connect to register file
    decoder_inst : decoder
    port map(
        instr => instr,
        opcode => opcode,
        rd => rd,
        funct3 => funct3,
        rs1 => rs1,
        rs2 => rs2,
        funct7 => funct7
    );

    register_file_inst : register_file
    port map(
        clk => clk,
        rst => rst,
        rs1_addr => rs1,
        rs2_addr => rs2,
        rs1_data => rs1_data,
        rs2_data => rs2_data,
        rd_addr => rd,
        rd_data => wb_data,
        rd_we => rd_we
    );

    imm_generator_inst : imm_generator
    port map(
        instr => instr,
        imm => imm
    );

    mux_alu_src_a_inst : mux_alu_src_a
    port map(
        rs1_data => rs1_data,
        pc => pc,
        src_a_sel => src_a_sel,
        src_a => src_a
    );

    mux_alu_src_b_inst : mux_alu_src_b
    port map(
        rs2_data => rs2_data,
        imm => imm,
        src_b_sel => src_b_sel,
        src_b => src_b
    );

    alu_inst : alu
    port map(
        src_a => src_a,
        src_b => src_b,
        alu_op => alu_op,
        alu_result => alu_result,
        alu_flags => alu_flags
    );

    mux_wb_inst : mux_wb
    port map(
        alu_result => alu_result,
        wb_lsu_data => data_reg_out,
        pc_plus_4 => std_logic_vector(unsigned(pc) + 4),
        imm => imm,
        wb_sel => wb_sel,
        wb_data => wb_data
    );

    branch_logic_inst : branch_logic
    port map(
        rs1_data => rs1_data,
        rs2_data => rs2_data,
        branch_sel => funct3,
        branch_cond => branch_cond
    );
end Behavioral;