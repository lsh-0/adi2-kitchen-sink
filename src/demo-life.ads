pragma Ada_2022;

with Interfaces;

--  Conway's Game of Life on a torus: the top edge wraps to the bottom and
--  the left edge to the right, so every cell has eight neighbours.
package Demo.Life with Pure is

   Width  : constant := 96;
   Height : constant := 64;

   subtype Row    is Natural range 0 .. Height - 1;
   subtype Column is Natural range 0 .. Width - 1;

   --  The set of live cells, held as a packed bitmap: membership is the
   --  only question the rules ask, and 768 bytes copy cheaply enough for
   --  `Step` to return a new generation rather than mutate one.
   type Grid is array (Row, Column) of Boolean with Pack;

   Empty : constant Grid := [others => [others => False]];

   function Population (G : Grid) return Natural;

   function Neighbours (G : Grid; R : Row; C : Column) return Natural;
   --  Counts the live cells among the eight around (`R`, `C`), wrapping at
   --  the edges.

   function Step (G : Grid) return Grid;
   --  Returns the next generation: a live cell with two or three live
   --  neighbours survives, and a dead cell with exactly three is born.

   --  A pattern is a set of offsets from its top-left corner.
   type Offset is record
      Down, Right : Natural;
   end record;
   type Pattern is array (Positive range <>) of Offset;

   Glider : constant Pattern :=
     [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)];

   R_Pentomino : constant Pattern :=
     [(0, 1), (0, 2), (1, 0), (1, 1), (2, 1)];

   Lightweight_Spaceship : constant Pattern :=
     [(0, 1), (0, 4), (1, 0), (2, 0), (2, 4), (3, 0), (3, 1), (3, 2), (3, 3)];

   function Place
     (G : Grid; P : Pattern; Top : Row; Left : Column) return Grid;
   --  Returns `G` with every cell of `P` set live, wrapping at the edges.

   subtype Seed is Interfaces.Unsigned_32 range 1 .. Interfaces.Unsigned_32'Last;

   function Next (S : Seed) return Seed;
   --  Advances a xorshift32 generator. Zero is its one fixed point, which
   --  the subtype excludes.

   subtype Percent is Natural range 0 .. 100;

   function Random (S : Seed; Density : Percent) return Grid;
   --  Returns a grid in which each cell is live with roughly `Density`
   --  percent probability. The same seed always gives the same grid.

   --  An RGBA32 pixel: the byte order `Adi.Widget.Texture_View.RGBA`
   --  expects.
   type Colour is record
      R, G, B, A : Interfaces.Unsigned_8;
   end record with Size => 32;

   Cell_Size : constant := 4;
   --  Screen pixels per cell edge; the last row and column of each cell
   --  are left as the gap between cells.

   Pixel_Width  : constant := Width * Cell_Size;
   Pixel_Height : constant := Height * Cell_Size;

   type Image is array (0 .. Pixel_Height - 1, 0 .. Pixel_Width - 1) of Colour
     with Pack;

   procedure Render (G : Grid; Live, Dead, Gap : Colour; Into : out Image);
   --  Draws `G` into `Into`. A procedure rather than a function because the
   --  image is 384 KiB: the caller keeps one buffer and reuses it.

end Demo.Life;
