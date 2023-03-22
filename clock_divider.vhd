-------------------------------------------------
-- filename : clock_divider.vhd
-- date     : 19 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the implementation
-- of a clock divider, to be used with a
-- clock generator.
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;

entity clock_divider is
  generic (
    NUM_CLKS    : integer := 2
  );
  port (
    clkIn       : in    std_logic;
    clksOut     :   out std_logic_vector(NUM_CLKS-1 downto 0); -- make nonspecific/depend on mult and div
    mult        : in    integer         (NUM_CLKS-1 downto 0);
    div         : in    integer         (NUM_CLKS-1 downto 0);
    phase       : in    integer         (NUM_CLKS-1 downto 0)
  );
end entity clock_divider;

architecture RTL of clock_divider is

signal clk_s         : std_logic_vector(NUM_CLKS-1 downto 0);

begin

  clk_s[0] <= clkIn; -- first clock should be our input, just to make things easy

  -- multiply (the frequency)
  generate ii for NUM_CLKS;
    mult_proc : process(clkIn)
    begin
      for(shortint a = 0; a < mult[ii]; a++) begin
        wait until rising_edge(clkIn);
      end
      clk_s[ii] <= '1';
    end
  end generate;

  input 100Mhz

  NUM_CLKS = 1 + mult'length + div'length + 


 9, 6
 2, 3

 100, 900, 600, 50, 33(!), 450, 300, 300, 200, 900, 5400(!), 20(!)

 -- fastest we could make: clkIn*2
 -- slowest we could make : ?


  

end architecture RTL;
