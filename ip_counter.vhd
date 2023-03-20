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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity ip_counter is
  generic (
    INCR_AMT   : integer   := 1;
    DECR_AMT   : integer   := 1;

    START_VAL  : integer   := 0;
    STOP_VAL   : integer   := -1;

    LOOP_IN    : std_logic := '1'
  );
  port (
    clk      : in    std_logic;
    rst      : in    std_logic;

    clearIn  : in    std_logic;
    enableIn : in    std_logic;

    incrCnt  : in    std_logic;
    decrCnt  : in    std_logic;

    countOut :   out integer;
    doneOut  :   out std_logic
  );
end entity ip_counter;

architecture RTL of ip_counter is

signal countOut_i : integer; -- internal countOut

begin

  counter_proc : process
  begin
    wait until rising_edge(clk);
    if(incrCnt = '1') then
      countOut_i <= countOut_i + INCR_AMT;
    end if;
    if(decrCnt = '1') then
      countOut_i <= countOut_i - DECR_AMT;
    end if;
    if(clearIn = '1' or rst = '1') then
      countOut_i <= START_VAL;
    end if;

    if(countOut_i = STOP_VAL) then
      doneOut <= '1';
      if(LOOP_IN = '1') then
        countOut_i <= START_VAL;
      end if;
    else
      doneOut <= '0';
    end if;    
  end process;

  countOut <= countOut_i;

end architecture RTL;