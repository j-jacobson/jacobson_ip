-------------------------------------------------
-- filename : clk_divider.vhd
-- date     : 24 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the implementation
-- of a clk divider, using counters.
--
-------------------------------------------------

library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library jacobson_ip;

entity clk_divider is
  generic (
    COUNT   : integer := 4
  );
  port (
    clkIn   : in    std_logic;
    rstIn   : in    std_logic;
    clkOut  :   out std_logic
  );
end;

architecture RTL of clk_divider is

signal count_s : integer;
signal done_s  : std_logic := '0';
signal temp_s  : std_logic := '0';

begin

  clk_div_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0, -- start at 0
    STOP_VAL   => COUNT-1,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clkIn,
    rst      => rstIn,
    clearIn  => '0',
    enableIn => '1',
    incrCnt  => '1',
    decrCnt  => '0', -- we will only be counting up
    countOut => count_s, -- probably don't need
    doneOut  => done_s
  );

  gen_clk : process(clkIn)
  begin
    if(rising_edge(clkIn)) then
      if(done_s = '1') then
        temp_s <= not temp_s;
      end if;
      clkOut <= temp_s;
    end if;
  end process;

end architecture RTL;