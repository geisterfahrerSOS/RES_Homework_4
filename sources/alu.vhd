library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ALU copy pasted from previous homework, might need adjustment.

entity alu is
   port (
      A: in std_logic_vector(31 downto 0);           
      B: in std_logic_vector(31 downto 0);           
      F: in std_logic_vector(2 downto 0);            -- ALU function selector
      R: out std_logic_vector(31 downto 0);          -- Result
      S: out std_logic_vector(3 downto 0)            -- Status flags
   );
end entity alu;

architecture behave of alu is 
   signal result_temp: std_logic_vector(31 downto 0);
   signal add_result_temp: std_logic_vector(32 downto 0);
   signal sub_result_temp: std_logic_vector(32 downto 0);
   signal zero: std_logic;
   signal sign: std_logic;
   signal overflow: std_logic;
   signal carry: std_logic;
begin 
   -- Function selection process
   process(A, B, F)
   begin
      case F is
         when "000" =>  -- 0
            result_temp <= (others => '0');
         when "001" =>  -- A
            result_temp <= A;
         when "010" =>  -- not A
            result_temp <= not A;
         when "011" =>  -- A AND B
            result_temp <= A and B;
         when "100" =>  -- A OR B
            result_temp <= A or B;
         when "101" =>  -- A XOR B
            result_temp <= A xor B;
         when "110" =>  -- A + B
            result_temp <= std_logic_vector(unsigned(A) + unsigned(B));
            add_result_temp <= std_logic_vector(('0' & unsigned(A)) + ('0' & unsigned(B)));
         when "111" =>  -- A - B
            result_temp <= std_logic_vector(unsigned(A) - unsigned(B));
            sub_result_temp <= std_logic_vector(('0' & unsigned(A)) - ('0' & unsigned(B)));
         when others =>
            result_temp <= (others => '0');
      end case;
   end process;

   -- Status flags calculation
   zero <= '1' when result_temp = x"00000000" else '0'; -- Zero flag is set if result is zero
   sign <= result_temp(31); -- Sign flag is the MSB of the result
   
   overflow <= '1' when (F = "110" and A(31) = B(31) and A(31) /= result_temp(31)) or -- when adding two numbers of the same sign results in a different sign there is an overflow in direction
                           (F = "111" and A(31) /= B(31) and A(31) /= result_temp(31)) -- when subtracting a number from another of different sign results in a different sign from the number being subtracted from there is an overflow in direction
                   else '0';
                   
   carry <= add_result_temp(32) when F = "110" else -- the MSB of the 33 bit usigned result of the addition
                 sub_result_temp(32) when F = "111" else -- the MSB of the 33 bit usigned result of the subtraction
                 '0';

   -- Output
   R <= result_temp;
   S <= zero & sign & overflow & carry;
end architecture behave;