-------------------------------------------------
-- filename : pong_logic.vhd
-- date     : 26 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the game logic 
-- for the implementation of Pong 
-- on the Nexys A7 development board.
-- 
-- Components: 
--             Game Logic
--             
---------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library pong_lib;     use pong_lib.pong_pack.all;
library jacobson_ip;

entity sound_driver is
  port (
    clk      : in    std_logic;
    rst      : in    std_logic;
    playIn   : in    std_logic;

    --noteIn   : in    note_t; -- TODO: Add this functionality.
    soundOut :   out std_logic;
    soundEn  :   out std_logic
  );

end entity sound_driver;
architecture RTL of sound_driver is

signal noteVal     : integer := 20000; -- A note?
signal noteTrigger : std_logic := '1';
signal soundOut_s  : std_logic;
signal STOP_VAL     : integer := 56000;
signal COUNT       : integer;

-- timer
signal timer_start : std_logic := '0';
signal timer_done  : std_logic;

-- oscillator
signal start_osc   : std_logic := '0';

begin

  oscillator_inst : entity jacobson_ip.ip_counter(RTL)
  port map (
    clk      => clk,
    rst      => rst,
    enableIn => start_osc,

    startVal => 0,
    stopVal  => STOP_VAL,

    countOut => COUNT,
    doneOut  => open
  );

  play_inst : entity jacobson_ip.ip_counter(RTL)
  port map(
    clk      => clk,
    rst      => rst,
    enableIn => timer_start,

    startVal => 0,
    stopVal  => 400000, -- 25MHz / ? = ?s

    countOut => open,
    doneOut  => timer_done
  );

  play_proc : process(clk, rst, playIn)
  begin
    if(rst = '1') then
      timer_start  <= '0';
    elsif(rising_edge(clk)) then
      if(playIn = '1') then
        timer_start  <= '1'; -- start the timer
        start_osc    <= '1'; -- start the sound
      elsif(timer_done = '1') then
        timer_start  <= '0'; -- stop the timer
        start_osc    <= '0'; -- stop the sound
      end if;
    end if;
  end process;

  -- TODO: Add case statement to choose which note to play?
  soundOut <= '1' when COUNT > noteVal else '0';
  soundEn  <= '1';

end architecture RTL;
