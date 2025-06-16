-- filepath: c:\Users\marco\Documents\GitHub\RES_Homework_4\sources\riscv_top.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity riscv_top is
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end riscv_top;

architecture Behavioral of riscv_top is
    -- Component declarations for the RISC-V processor
    component control_unit is
        port (
            clk : in std_logic;
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
            pc_sel : out std_logic_vector(2 downto 0); -- PC select output
            branch_sel : out std_logic_vector(2 downto 0); -- Branch select output
            mem_we : out std_logic -- Memory write enable signal, if needed
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
            DATA_WIDTH : integer := 32; -- Width of data bus
            ADDR_WIDTH : integer := 32 -- Width of address bus
        );
        port (
            clk : in std_logic; -- Clock input
            we : in std_logic; -- Write enable
            addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0); -- Address input
            data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0); -- Data input
            data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0) -- Data output
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
            wb_mem_data : in std_logic_vector(31 downto 0) -- Memory data input
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

    component uart is
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
    signal branch_sel : std_logic_vector(2 downto 0);
    signal mem_we : std_logic; -- Memory write enable signal, if needed

    signal branch_cond : std_logic;

    signal wb_data : std_logic_vector(31 downto 0);

    signal mem_data_out : std_logic_vector(31 downto 0); -- Data read from RAM

begin

    -- Instantiate the control unit
    control_unit_inst : control_unit
    port map(
        clk => clk,
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
        pc_sel => pc_sel,
        branch_sel => branch_sel
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

    -- Instantiate RAM for data memory
    ram_inst : ram
    generic map(
        DATA_WIDTH => 32, -- Width of data bus
        ADDR_WIDTH => 32 -- Width of address bus
    )
    port map(
        clk => clk,
        we => mem_we, -- Write enable signal
        addr => alu_result, -- Address for RAM access, typically the ALU result
        data_in => rs2_data, -- Data to write into RAM
        data_out => mem_data_out -- Data read from RAM
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
        pc_plus_4 => std_logic_vector(unsigned(pc) + 4),
        imm => imm,
        wb_sel => wb_sel,
        wb_mem_data => mem_data_out,
        wb_data => wb_data
    );

    branch_logic_inst : branch_logic
    port map(
        rs1_data => rs1_data,
        rs2_data => rs2_data,
        branch_sel => branch_sel,
        branch_cond => branch_cond
    );
end Behavioral;