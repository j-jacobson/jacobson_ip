-------------------------------------------------
-- filename : ip_counter.vhd
-- date     : 19 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the implementation
-- of a counter.
--
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;

entity ip_counter is
  generic (
    INCR_AMT   : integer := 1;

    START_VAL  : integer := 0;
    STOP_VAL   : integer := -1;

    LOOP_IN    : std_logic := '1'
  );
  port (
    clk      : in    std_logic;
    rst      : in    std_logic;
    enableIn : in    std_logic;

    countOut :   out integer;
    doneOut  :   out std_logic
  );
end entity ip_counter;

architecture RTL of ip_counter is

signal countOut_i : integer; -- internal countOut
signal doneOut_i  : std_logic := '0';

begin

  counter_proc : process(clk, rst, enableIn)
  begin
    if(rst = '1') then
      countOut_i <= START_VAL;
    elsif(rising_edge(clk) and (enableIn = '1')) then
      if(countOut_i = STOP_VAL) then
        countOut_i <= START_VAL;
      else
        countOut_i <= countOut_i + 1;
      end if;
    end if;
  end process;


  done_proc : process(clk, enableIn)
  begin
    if(rising_edge(clk) and (enableIn = '1')) then
      if(countOut_i = STOP_VAL) then
        doneOut_i <= '1';
      else
        doneOut_i <= '0';
      end if;
    end if;
  end process;

  countOut <= countOut_i;
  doneOut  <= doneOut_i;

end architecture RTL;