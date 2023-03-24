-------------------------------------------------
-- filename : vga_counter.vhd
-- date     : 19 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the implementation
-- of a vga counter. It gives you the coordinate
-- you are drawing at that point in time.
--
-- Components: HSync and VSync Counters
--
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library jacobson_ip;

entity vga_counter is
  generic (
    HSync_Front   : integer := 16;
    HSync_Visible : integer := 640;
    HSync_Back    : integer := 48;
    HSync_SyncP   : integer := 96;

    VSync_Front   : integer := 10;
    VSync_Visible : integer := 480;
    VSync_Back    : integer := 33;
    VSync_SyncP   : integer := 2
  );
  port (
    clkIn         : in    std_logic;
    rstIn         : in    std_logic;
    enableIn      : in    std_logic;

    inVisibleArea :   out std_logic;
    xValue        :   out std_logic_vector(31 downto 0); -- horizontal position
    yValue        :   out std_logic_vector(31 downto 0); -- veritical position

    HSync         :   out std_logic;
    VSync         :   out std_logic
  );
end entity vga_counter;

architecture RTL of vga_counter is

  -- HSync
  signal hsyncCnt_s      : integer;
  signal hsyncLineDone_s : std_logic;
  signal HSync_s         : std_logic;

  -- VSync
  signal vsyncCnt_s      : integer;
  signal vsyncLineDone_s : std_logic;
  signal VSync_s         : std_logic;

  -- Helper signals
  signal hVisible_s      : std_logic;
  signal vVisible_s      : std_logic;
  signal inVisibleArea_s : std_logic;
begin

  hsync_counter_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0, -- start at 0
    STOP_VAL   => HSync_Front + HSync_Visible + HSync_Back + HSync_SyncP,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clkIn, -- might have to be a different clock
    rst      => rstIn,
    clearIn  => '0', -- no need to clear, other than in reset
    enableIn => enableIn,
    incrCnt  => enableIn,
    decrCnt  => '0', -- we will only be counting up
    countOut => hsyncCnt_s,
    doneOut  => hsyncLineDone_s
  );

  vsync_counter_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0, -- start at 0
    STOP_VAL   => VSync_Front + VSync_Visible + VSync_Back + VSync_SyncP,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clkIn, -- might have to be a different clock
    rst      => rstIn,
    clearIn  => '0', -- rst will take car of this (?)
    enableIn => hsyncLineDone_s, -- when a horizontal line is done, increment the vertical counter
    incrCnt  => hsyncLineDone_s, -- when a horizontal line is done, increment the vertical counter
    decrCnt  => '0', -- we will only be counting up
    countOut => vsyncCnt_s,
    doneOut  => vsyncLineDone_s
  );

  -- syncOutput : set sync pulse
  -- Horizontal Sync
  HSync_s <= '0' when ((hsyncCnt_s >= HSync_Front + HSync_Visible) and (hsyncCnt_s < HSync_Front + HSync_Visible + HSync_SyncP)) else '1';
  -- Vertical Sync
  VSync_s <= '0' when ((HSync_s = '0') and (vsyncCnt_s >= VSync_Front + VSync_Visible) and (vsyncCnt_s < VSync_Front + VSync_Visible + VSync_SyncP)) else '1';

  -- convertToCartesian : make the xValue and yValue easier to work with by other programs.
  -- In visible horizontal
  hVisible_s <= '1' when (hsyncCnt_s < HSync_Visible) else '0';
  -- In visible vertical area?
  vVisible_s <= '1' when (vsyncCnt_s < VSync_Visible) else '0';
  -- inVisibleArea?
  inVisibleArea_s <= '1' when ((hVisible_s = '1') and (vVisible_s = '1')) else '0';

  -- Output pixel count
  xValue <= std_logic_vector(to_unsigned((hsyncCnt_s), xValue'length)) when inVisibleArea_s = '1' and (hsyncCnt_s >= 0) else (others => '0');
  yValue <= std_logic_vector(to_unsigned((vsyncCnt_s), yValue'length)) when inVisibleArea_s = '1' and (vsyncCnt_s >= 0) else (others => '0');
  HSync  <= HSync_s;
  VSync  <= VSync_s;
  inVisibleArea <= inVisibleArea_s;
end architecture RTL;