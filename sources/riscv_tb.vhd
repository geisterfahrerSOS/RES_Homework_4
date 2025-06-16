library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavioral of riscv_tb is
    -- Component declaration
    component riscv_top is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic
        );
    end component;

    -- Signal declarations
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '1';
    
    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: riscv_top port map (
        clk     => clk_tb,
        rst     => rst_tb
    );

    -- Clock process
    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset for 100 ns
        rst_tb <= '1';
        wait for 100 ns;
        
        -- Release reset
        rst_tb <= '0';
        
        -- Wait for some clock cycles to observe behavior
        wait for 1000 ns;
        
        -- End simulation
        wait;
    end process;

end behavioral;