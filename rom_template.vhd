-- template for a simple unpipelined ROM

-- V. 1.0

-- ports:
    -- addr             : address input port (addr_width bits wide)
    -- data             : data output (data_width bits wide)
    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    generic(
        addr_width  : integer := 8; -- required bits to store 16 elements
        data_width : integer := 32 -- each element has 7-bits
        );
port(
    addr : in std_logic_vector(addr_width-1 downto 0);
    data : out std_logic_vector(data_width-1 downto 0)
);
end ROM;

architecture ROM_arch of ROM is
  type rom_type is array (0 to addr_width-1) of std_logic_vector(data_width-1 downto 0);
  signal ROM_array : rom_type := (
	
--init_data
	
  (others=>'0')  -- we add a dummy entry to leave out the stupid ',' for the last item
  );

begin

    data <= ROM_array(to_integer(unsigned(addr)));
	
end ROM_arch; 