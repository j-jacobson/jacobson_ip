-------------------------------------------------
-- filename : pixel_pack.vhd
-- date     : 25 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the type package for
-- the implementation of pixel based games 
-- on the Nexys A7 development board.
-- 
-- Components: 
--    Type definitions
--    * Single Coordinate
--    * Coordinate Group
--    * Group of groups of coordinates
--    Function Definitions
--    * integer to SLV
--    * check if a coordinate is within a plane
--    * shifting a group of coordinates
--    * check if two planes intersect
--    Overloaded Operators
--    * Overload '+', '-' to add coordinates and ints
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;

package pixel_pack is

  constant v_Size     : integer := 480;
  constant h_Size     : integer := 640;
  constant COORD_LEN  : integer := 32;
  constant XSMALL     : integer := 30;
  constant SMALL      : integer := 50;
  constant NORMAL     : integer := 80;
  constant LARGE      : integer := 150;
  constant FULL       : integer := 480;

  -- single coordinate (x)
  subtype coord_t       is std_logic_vector(COORD_LEN-1 downto 0); -- leave coordinate depth open
  -- array of coords (x0, x1, ... , xN-1 , xN)
  type    coords_t      is array (natural range <>) of coord_t;
  -- array of arrays of coords ((x0, x1, x2, x3), ... , (z0, z1, z2, z3))
  type    multiCoords_t is array (natural range <>) of coords_t(0 to 3);
  -- int to SLV function
  function toSLV(int: integer) return std_logic_vector;
  -- function to see if a pixel is within a plane (x0, x1, y0, y1)
  function inCoords(x, y: coord_t;  coords : coords_t(0 to 3)) return boolean;
  -- function to shift coords of a plane
  function shiftCoords(direction: std_logic_vector(0 to 3); coords : coords_t(0 to 3)) return coords_t;
  -- function to turn an integer into a picture of pixels
  function intToPixels(int: integer; bounds: coords_t(0 to 3)) return multiCoords_t;
  -- Overload + operator to increment the coords.
  function "+" (L: coords_t(0 to 3); R: std_logic_vector(0 to 3)) return coords_t;
  function "+" (L, R: coords_t(0 to 3)) return coords_t;
  -- Return true if two objects are touching.
  function isTouching (L, R: coords_t(0 to 3)) return boolean;
  -- Overload - operator to decrement the coords.
  function "-" (L: coords_t(0 to 3); R: std_logic_vector(0 to 3)) return coords_t;
  -- Overload - operator to decrement the coords.
  function "-" (L, R: coords_t(0 to 3)) return coords_t;
end package;

package body pixel_pack is

  function toSLV(int: integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(int,  COORD_LEN));
  end function;

  function inCoords(x, y   : coord_t;
                    coords : coords_t(0 to 3)
                    ) return boolean is
    variable isIn : boolean := false;
  begin
    if( x >= coords(0)  and 
        x <= coords(1)  and 
        y >= coords(2)  and 
        y <= coords(3)) then
      isIn := true;
    end if;

    return isIn;
  end function;

  function in5Planes(x, y: coord_t; mcoords: multiCoords_t(0 to 4)) return boolean is
    variable isIn : boolean := false;
  begin
    if(inCoords(x, y, mcoords(0)) or
       inCoords(x, y, mcoords(1)) or
       inCoords(x, y, mcoords(2)) or
       inCoords(x, y, mcoords(3)) or
       inCoords(x, y, mcoords(4))) then
      isIn := true;
    end if;
    return isIn;
  end function;

  function shiftCoords(direction: std_logic_vector(0 to 3);
                       coords   : coords_t(0 to 3)
                      )return coords_t is
  variable shifted : coords_t(0 to 3) := coords;
  begin
    if(direction(0) = '1' and coords(2) > 0) then -- up
      shifted(2) := coords(2) - toSLV(1);
      shifted(3) := coords(3) - toSLV(1);
    elsif(direction(1) = '1' and coords(3) < v_Size-1) then -- down
      shifted(2) := coords(2) + toSLV(1);
      shifted(3) := coords(3) + toSLV(1);
    end if;

    if(direction(2) = '1' and coords(0) > 0) then -- left
      shifted(0) := coords(0) - toSLV(1);
      shifted(1) := coords(1) - toSLV(1);
    elsif(direction(3) = '1' and coords(1) < h_Size-1) then -- right
      shifted(0) := coords(0) + toSLV(1);
      shifted(1) := coords(1) + toSLV(1);
    end if;
    return shifted;
  end function;

  function intToPixels(int: integer;
                       bounds: coords_t(0 to 3)
                      ) return multiCoords_t is
    variable pixelsOut : multiCoords_t(0 to 6) :=
    (((bounds(0),    bounds(1),    bounds(2),             bounds(2)+4)),
     ((bounds(1)-4), bounds(1),    bounds(2),             bounds(3)-bounds(2)),
     ((bounds(1)-4), bounds(1),    bounds(3)-bounds(2),   bounds(3)),
     ((bounds(0)),   bounds(1),    bounds(3)-4,           bounds(3)),
     ((bounds(0)),   bounds(0)+4,  bounds(3)-bounds(2),   bounds(3)),
     ((bounds(0)),   bounds(0)+4,  bounds(2),             bounds(3)-bounds(2)),
     (bounds(0),     bounds(1),    bounds(3)-bounds(2)-2, bounds(3)-bounds(2)+2));
    variable segmentOff : coords_t(0 to 3) := (toSLV(h_Size+1), toSLV(h_Size+1),    toSLV(v_Size+1), toSLV(v_Size+1));
  begin
    if(int = 0) then
      pixelsOut(6) := segmentOff;
    elsif(int = 1) then
      pixelsOut(0) := segmentOff;
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
      pixelsOut(6) := segmentOff;
    elsif(int = 2) then
      pixelsOut(2) := segmentOff;
      pixelsOut(5) := segmentOff;
    elsif(int = 3) then
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
    elsif(int = 4) then
      pixelsOut(0) := segmentOff;
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
    elsif(int = 5) then
      pixelsOut(1) := segmentOff;
      pixelsOut(4) := segmentOff;
    elsif(int = 6) then
      pixelsOut(1) := segmentOff;
    elsif(int = 7) then
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
      pixelsOut(6) := segmentOff;
    elsif(int = 8) then
    elsif(int = 9) then
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
    else
      pixelsOut(0) := segmentOff;
      pixelsOut(1) := segmentOff;
      pixelsOut(2) := segmentOff;
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
    end if;

    return pixelsOut;
  end function;

  function "+" (L: coords_t(0 to 3); R: std_logic_vector(0 to 3)) return coords_t is
    variable Rtemp  : coords_t(0 to 3);
    variable slvOut : coords_t(0 to 3);
  begin
    Rtemp(0) := (others => R(0));
    Rtemp(1) := (others => R(1));
    Rtemp(2) := (others => R(2));
    Rtemp(3) := (others => R(3));

    slvOut := L + Rtemp;
    return slvOut;
  end function;

  function "-" (L: coords_t(0 to 3); R: std_logic_vector(0 to 3)) return coords_t is
    variable Rtemp  : coords_t(0 to 3);
    variable slvOut : coords_t(0 to 3);
  begin
    Rtemp(0) := (others => R(0));
    Rtemp(1) := (others => R(1));
    Rtemp(2) := (others => R(2));
    Rtemp(3) := (others => R(3));

    slvOut := L - Rtemp;
    return slvOut;
  end function;

  function "+" (L, R: coords_t(0 to 3)) return coords_t is
    variable slvOut : coords_t(0 to 3);
  begin

    slvOut(0) := std_logic_vector(signed(L(0)) + signed(R(0)));
    slvOut(1) := std_logic_vector(signed(L(1)) + signed(R(1)));
    slvOut(2) := std_logic_vector(signed(L(2)) + signed(R(2)));
    slvOut(3) := std_logic_vector(signed(L(3)) + signed(R(3)));

    return slvOut;
  end function;

  function "-" (L, R: coords_t(0 to 3)) return coords_t is
    variable slvOut : coords_t(0 to 3);
  begin

    slvOut(0) := std_logic_vector(signed(L(0)) - signed(R(0)));
    slvOut(1) := std_logic_vector(signed(L(1)) - signed(R(1)));
    slvOut(2) := std_logic_vector(signed(L(2)) - signed(R(2)));
    slvOut(3) := std_logic_vector(signed(L(3)) - signed(R(3)));

    return slvOut;
  end function;

  function isInside(pointX, pointY: coord_t; area: coords_t) return boolean is
    variable inside : boolean := false;
  begin
    if(pointX >= area(0) and pointX <= area(1) and pointY >= area(2) and pointY <= area(3)) then
      inside := true;
    end if;
    return inside;
  end function;

  function isInside(area1, area2: coords_t) return boolean is
    variable inside : boolean := false;
  begin
    if(isInside(area1(0), area1(2), area2)
    or isInside(area1(0), area1(3), area2)
    or isInside(area1(1), area1(2), area2)
    or isInside(area1(1), area1(3), area2)) then
      inside := true;
    end if;
    return inside;
  end function;

 function isTouching (L, R: coords_t(0 to 3)) return boolean is
    variable touching : boolean := false;
  begin
    if(isInside(L, R) or isInside(R, L)) then
      touching := true;
    end if;
    return touching;
  end function;

end package body pixel_pack;