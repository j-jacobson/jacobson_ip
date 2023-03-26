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

    inVisibleArea :   out std_logic;
    xCoord        :   out std_logic_vector(31 downto 0); -- horizontal position
    yCoord        :   out std_logic_vector(31 downto 0); -- veritical position
    HSync         :   out std_logic;
    VSync         :   out std_logic
  );
end entity vga_driver;

architecture RTL of vga_driver is

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
      xCoord        => xCoord,
      yCoord        => yCoord,
      HSync         => HSync,
      VSync         => VSync
    );

end architecture RTL;