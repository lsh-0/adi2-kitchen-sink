pragma Ada_2022;

with Interfaces;

with Adi.Widget;              use Adi.Widget;
with Adi.Widget.Button;
with Adi.Widget.Label;
with Adi.Widget.Texture_View;

with Shell_UI;

with Demo.Colours;
with Demo.Life;               use Demo.Life;
with Demo.Meter;
with Demo.Status;
with Demo.Text;
with Demo.Theme;
with Demo.UI;

package body Demo.Pages.Canvas is

   package Page renames Demo.UI.Canvas_Page;

   use type Interfaces.Unsigned_32;
   use type Shell_UI.Page;

   Board      : Grid := Empty;
   Generation : Natural := 0;
   State      : Seed := 16#2545_F491#;
   Running    : Boolean := True;
   Rate       : Positive := 15;
   Waited     : Duration := 0.0;
   Stale      : Boolean := True;
   Since_Text : Duration := 1.0;
   --  Time since the readout was rewritten. A label whose text changes
   --  lays the window out again, so the readout follows the board at
   --  four updates a second rather than at the board's rate.

   --  One buffer for the run, reused by every upload.
   Pixels : aliased Image;

   Live_Colour, Dead_Colour, Gap_Colour : Colour;

   function To_Colour (Property : String; Default : Demo.Colours.RGB) return Colour
   is
      C : constant Demo.Colours.RGB :=
        Demo.Colours.Parse_Hex (Demo.Theme.Colour (Property), Default);
   begin
      return (Interfaces.Unsigned_8 (C.R), Interfaces.Unsigned_8 (C.G),
              Interfaces.Unsigned_8 (C.B), 255);
   end To_Colour;

   procedure Take_Palette is
   begin
      Live_Colour := To_Colour ("--accent", (126, 166, 255));
      Dead_Colour := To_Colour ("--board-bg", (12, 14, 18));
      Gap_Colour  := To_Colour ("--surface", (25, 28, 35));
      Stale := True;
   end Take_Palette;

   procedure On_Theme (Theme : Demo.Theme.Theme_Kind) is
      pragma Unreferenced (Theme);
   begin
      Take_Palette;
   end On_Theme;

   procedure Draw is
      Population : constant Natural := Demo.Life.Population (Board);
   begin
      Demo.Meter.Set_Value
        (Page.Density, Float (Population) / Float (Width * Height));
      Stale := False;
      Render (Board, Live_Colour, Dead_Colour, Gap_Colour, Pixels);
      Adi.Widget.Texture_View.Set_Pixels
        (Page.Board,
         Data   => Pixels'Address,
         Width  => Pixel_Width,
         Height => Pixel_Height,
         Pitch  => Pixel_Width * 4);
      if Since_Text >= 0.25 or else not Running then
         Since_Text := 0.0;
         Adi.Widget.Label.Set_Text
           (Page.Generation,
            "Generation " & Text.Image (Generation) & ", "
            & Text.Image (Population) & " live cells of"
            & Natural'Image (Width * Height));
      end if;
   end Draw;

   procedure Advance is
   begin
      Board := Step (Board);
      Generation := Generation + 1;
      Stale := True;
   end Advance;

   function Showing return Boolean is
     (Shell_UI.Page_Stack.Get_Active (Demo.UI.Pages) = Shell_UI.Canvas);

   procedure Tick (DT : Duration) is
   begin
      if not Showing then
         return;
      end if;
      Since_Text := Since_Text + DT;
      if Running then
         Waited := Waited + DT;
         if Waited >= 1.0 / Rate then
            Waited := 0.0;
            Advance;
         end if;
      end if;
      if Stale then
         Draw;
      end if;
   end Tick;

   procedure Reseed (G : Grid; What : String) is
   begin
      Board := G;
      Generation := 0;
      Stale := True;
      Demo.Status.Report ("Board: " & What);
   end Reseed;

   procedure On_Play (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Running := not Running;
      Adi.Widget.Button.Set_Text (Page.Play, (if Running then "Pause" else "Play"));
   end On_Play;

   procedure On_Step (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Advance;
   end On_Step;

   procedure On_Randomise (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      State := Next (State);
      Reseed (Random (State, 28), "random, 28 percent live");
   end On_Randomise;

   procedure On_Gliders (W : Widget_Handle) is
      pragma Unreferenced (W);
      G : Grid := Board;
   begin
      for I in 0 .. 5 loop
         State := Next (State);
         G := Place (G, Glider,
                     Top  => Natural (State mod Height),
                     Left => Natural (Interfaces.Shift_Right (State, 8) mod Width));
      end loop;
      G := Place (G, Lightweight_Spaceship, Top => Height / 2, Left => 2);
      Board := G;
      Stale := True;
      Demo.Status.Report ("Board: six gliders and a spaceship added");
   end On_Gliders;

   procedure On_Clear (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Reseed (Empty, "cleared");
   end On_Clear;

   procedure On_Speed (W : Widget_Handle; Value : Integer) is
      pragma Unreferenced (W);
   begin
      Rate := Integer'Max (1, Value);
      Adi.Widget.Label.Set_Text (Page.Speed_Value, Text.Image (Rate) & "/s");
   end On_Speed;

   procedure Wire is
   begin
      Page.On_Play := On_Play'Access;
      Page.On_Step := On_Step'Access;
      Page.On_Randomise := On_Randomise'Access;
      Page.On_Gliders := On_Gliders'Access;
      Page.On_Clear := On_Clear'Access;
      Page.On_Speed := On_Speed'Access;
   end Wire;

   procedure Start (Window : Adi.Window.Window_Handle) is
   begin
      Take_Palette;
      Board := Place (Random (State, 20), R_Pentomino, Height / 2, Width / 2);
      Demo.Theme.Subscribe (On_Theme'Access);
      Adi.Window.Connect_Tick (Window, Tick'Access);
   end Start;

end Demo.Pages.Canvas;
