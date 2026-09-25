with Adi.Window;

--  Conway's Game of Life drawn through a texture view.
package Demo.Pages.Canvas is

   procedure Wire;

   procedure Start (Window : Adi.Window.Window_Handle);
   --  Seeds the board and steps it from the window tick. Steps and
   --  uploads happen only while the Canvas page is showing.

end Demo.Pages.Canvas;
