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
  signal hsyncCnt_s      : integer := 0;
  signal hsyncLineDone_s : std_logic;

  -- VSync
  signal vsyncCnt_s      : integer := 0;
  signal vsyncLineDone_s : std_logic;

  -- Helper signals
  signal hVisible_s      : std_logic;
  signal vVisible_s      : std_logic;
  signal inVisibleArea_s : std_logic;
begin

  hsync_counter_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0,
    STOP_VAL   => HSync_Front + HSync_Visible + HSync_Back + HSync_SyncP - 1,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clkIn,
    rst      => rstIn,
    enableIn => '1',
    countOut => hsyncCnt_s,
    doneOut  => hsyncLineDone_s
  );

  vsync_counter_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0,
    STOP_VAL   => VSync_Front + VSync_Visible + VSync_Back + VSync_SyncP - 1,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clkIn,
    rst      => rstIn,
    enableIn => hsyncLineDone_s, -- when a horizontal line is done, increment the vertical counter
    countOut => vsyncCnt_s,
    doneOut  => vsyncLineDone_s
  );

  -- syncOutput : set sync pulse
  -- Horizontal Sync
  HSync <= '1' when ((hsyncCnt_s < HSync_Front + HSync_Visible) or (hsyncCnt_s >= HSync_Front + HSync_Visible + HSync_SyncP) or (rstIn = '1')) else '0';
  -- Vertical Sync
  VSync <= '1' when ((vsyncCnt_s < VSync_Front + VSync_Visible) or (vsyncCnt_s >= VSync_Front + VSync_Visible + VSync_SyncP) or (rstIn = '1')) else '0';

  -- In visible horizontal?
  hVisible_s <= '1' when (hsyncCnt_s < HSync_Visible) else '0';
  -- In visible vertical?
  vVisible_s <= '1' when (vsyncCnt_s < VSync_Visible) else '0';
  -- inVisibleArea?
  inVisibleArea_s <= '1' when ((hVisible_s = '1') and (vVisible_s = '1')) else '0';

  -- Output pixel count
  xValue <= std_logic_vector(to_unsigned((hsyncCnt_s), xValue'length)) when inVisibleArea_s = '1' and (hsyncCnt_s >= 0) else (others => '0');
  yValue <= std_logic_vector(to_unsigned((vsyncCnt_s), yValue'length)) when inVisibleArea_s = '1' and (vsyncCnt_s >= 0) else (others => '0');
  inVisibleArea <= inVisibleArea_s;
end architecture RTL;