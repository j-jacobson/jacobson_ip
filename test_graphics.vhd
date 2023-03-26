-------------------------------------------------
-- filename : test_graphics.vhd
-- date     : 25 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is a test 
-- the implementation of Pong 
-- on the Nexys A7 development board.
-- 
-- Components: 
--             Graphics for test image.
--             Different colored vertical lines.
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library pong_lib;     use pong_lib.pong_pack.all;
library jacobson_ip;

entity test_graphics is
  generic (
    VGA_DEPTH : integer := 12
  );
  port (
    inVisibleArea : in    std_logic;
    xCoord        : in    coord_t;
    yCoord        : in    coord_t;

    RED           :   out std_logic_vector((VGA_DEPTH/3)-1 downto 0);
    GREEN         :   out std_logic_vector((VGA_DEPTH/3)-1 downto 0);
    BLUE          :   out std_logic_vector((VGA_DEPTH/3)-1 downto 0)
  );
end entity test_graphics;

architecture RTL of test_graphics is

signal pixel_s : std_logic_vector(2 downto 0);

begin

  pixel_s <= xCoord(8 downto 6) when (inVisibleArea = '1') else (others => '0');

  RED   <= (others => '1') when pixel_s(0) = '1' else (others => '0');
  GREEN <= (others => '1') when pixel_s(1) = '1' else (others => '0');
  BLUE  <= (others => '1') when pixel_s(2) = '1' else (others => '0');

end architecture RTL;