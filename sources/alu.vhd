library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.alu_op.all;

entity alu is
    port (
        src_a: in std_logic_vector(31 downto 0); -- Source register 1 data
        src_b: in std_logic_vector(31 downto 0); -- Source register 2 data or immediate
        alu_op: in std_logic_vector(3 downto 0); -- ALU operation code
        alu_result: out std_logic_vector(31 downto 0); -- ALU result output
        alu_flags: out std_logic_vector(3 downto 0) -- ALU flags (zero, carry, overflow, negative)
    );
end entity alu;
    
architecture behavioral of alu is
    signal result_temp : std_logic_vector(31 downto 0);
    signal add_result_temp : std_logic_vector(32 downto 0);
    signal sub_result_temp : std_logic_vector(32 downto 0);
    signal zero : std_logic;
    signal sign : std_logic;
    signal overflow : std_logic;
    signal carry : std_logic;

begin
    process(src_a, src_b, alu_op)
    begin
        add_result_temp <= (others => '0');
        sub_result_temp <= (others => '0');

        case alu_op is
            when ALU_ADD =>
                result_temp <= std_logic_vector(signed(src_a) + signed(src_b));
                add_result_temp <= std_logic_vector(('0' & unsigned(src_a)) + ('0' & unsigned(src_b)));

            when ALU_SUB =>
                result_temp <= std_logic_vector(signed(src_a) - signed(src_b));
                sub_result_temp <= std_logic_vector(('0' & unsigned(src_a)) - ('0' & unsigned(src_b)));

            when ALU_AND =>
                result_temp <= src_a and src_b;

            when ALU_OR =>
                result_temp <= src_a or src_b;

            when ALU_XOR =>
                result_temp <= src_a xor src_b;

            when ALU_SLL =>
                result_temp <= std_logic_vector(shift_left(unsigned(src_a), to_integer(unsigned(src_b(4 downto 0)))));

            when ALU_SRL =>
                result_temp <= std_logic_vector(shift_right(unsigned(src_a), to_integer(unsigned(src_b(4 downto 0)))));

            when ALU_SRA =>
                result_temp <= std_logic_vector(shift_right(signed(src_a), to_integer(unsigned(src_b(4 downto 0)))));

            when ALU_SLT =>
                if signed(src_a) < signed(src_b) then
                    result_temp <= x"00000001";
                else
                    result_temp <= x"00000000";
                end if;

            when ALU_SLTU =>
                if unsigned(src_a) < unsigned(src_b) then
                    result_temp <= x"00000001";
                else
                    result_temp <= x"00000000";
                end if;

            when ALU_PASS =>
                result_temp <= src_b;

            when ALU_NOP =>
                result_temp <= (others => '0');

            when others =>
                result_temp <= (others => '0');
        end case;
    end process;

    -- Flags
    zero <= '1' when result_temp = x"00000000" else '0';
    sign <= result_temp(31);
    overflow <= '1' when 
        (alu_op = ALU_ADD and rs1_data(31) = rs2_data(31) and rs1_data(31) /= result_temp(31)) or
        (alu_op = ALU_SUB and rs1_data(31) /= rs2_data(31) and rs1_data(31) /= result_temp(31))
        else '0';

    carry <= add_result_temp(32) when alu_op = ALU_ADD else
             sub_result_temp(32) when alu_op = ALU_SUB else
             '0';

    -- Outputs
    alu_result <= result_temp;
    alu_flags <= zero & sign & overflow & carry;
end architecture behavioral;


                