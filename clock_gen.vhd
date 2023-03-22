-------------------------------------------------
-- filename : clock_gen.vhd
-- date     : 19 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the implementation
-- of a clock generator.
--
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;

entity clock_gen is
  port (
    clkIn                    : in    std_logic;
    rstIn                    : in    std_logic;

    clksOut                  :   out std_logic_vector(NUM_CLKS - 1 downto 0);
    rstsOut                  :   out std_logic_vector(NUM_CLKS - 1 downto 0)
  );
end entity clock_gen;

architecture RTL of clock_gen is

begin

  clk_div_inst : entity jacobson_ip.clock_divider
    port map (
      clkIn       <= clkIn,
      clksOut     <= clksOut,
      mult        <= {2, 3},
      div         <= {12, 1},
      phase       <= {50, 20}
    );

end architecture RTL;
