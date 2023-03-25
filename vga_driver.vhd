-------------------------------------------------
-- filename : vga_driver.vhd
-- date     : 20 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the implementation
-- of a vga driver. It determines the color pixel
-- to draw at a given point.
--
-- Components: vga_counter
--
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library jacobson_ip;

entity vga_driver is
  generic(
    VGA_DEPTH     : integer := 12;
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

    RED           :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    GREEN         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    BLUE          :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);

    RED_RTN       : in    std_logic;
    GREEN_RTN     : in    std_logic;
    BLUE_RTN      : in    std_logic;

    ID            : in    std_logic_vector (0 to 3);
    HSync         :   out std_logic;
    VSync         :   out std_logic
  );
end entity vga_driver;

architecture RTL of vga_driver is

signal inVisibleArea : std_logic;
signal xValue        : std_logic_vector(31 downto 0); -- horizontal position
signal yValue        : std_logic_vector(31 downto 0); -- veritical position
signal pixel_s       : std_logic_vector(2 downto 0);

begin

  vga_counter_inst : entity jacobson_ip.vga_counter(RTL)
    generic map (
      HSync_Front    => HSync_Front,
      HSync_Visible  => HSync_Visible,
      HSync_Back     => HSync_Back,
      HSync_SyncP    => HSync_SyncP,

      VSync_Front    => VSync_Front,
      VSync_Visible  => VSync_Visible,
      VSync_Back     => VSync_Back,
      VSync_SyncP    => VSync_SyncP
    )
    port map (
      clkIn         => clkIn,
      rstIn         => rstIn,
      enableIn      => enableIn,
      inVisibleArea => inVisibleArea,
      xValue        => xValue,
      yValue        => yValue,
      HSync         => HSync,
      VSync         => VSync
    );

  pixel_s <= xValue(8 downto 6) when (inVisibleArea = '1') else (others => '0');

  RED   <= (others => '1') when pixel_s(0) = '1' else (others => '0');
  GREEN <= (others => '1') when pixel_s(1) = '1' else (others => '0');
  BLUE  <= (others => '1') when pixel_s(2) = '1' else (others => '0');

end architecture RTL;