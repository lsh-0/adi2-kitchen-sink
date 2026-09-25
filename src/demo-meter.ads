pragma Ada_2022;

with Adi.Core;
with Adi.Widget;     use Adi.Widget;
with Adi.Widget.Box;
with Adi.Widget.Extension;

--  A widget defined outside the library: a horizontal bar filled to a
--  fraction. It draws three CSS parts and no fixed colours or sizes:
--  `::main` is the frame, `::scroll` the track inside its padding, and
--  `::indicator` the filled share of the track. `ui/widgets_extra.xml`
--  registers it as the `<meter>` tag.
package Demo.Meter is

   type Meter_Widget is new Adi.Widget.Box.Box_Widget with private;

   type Meter_Handle is private;

   function Create_Handle return Meter_Handle;

   function "+" (H : Meter_Handle) return Widget_Handle;

   function Is_Valid (H : Meter_Handle) return Boolean;

   subtype Fraction is Float range 0.0 .. 1.0;

   procedure Set_Value (H : Meter_Handle; Value : Fraction);
   --  Sets the filled share and redraws without laying out. A stale
   --  handle does nothing.

   function Get_Value (H : Meter_Handle) return Fraction;
   --  Returns 0.0 for a stale handle.

   overriding procedure Build_Items (W : in out Meter_Widget);
   overriding procedure Layout (W : in out Meter_Widget);
   overriding function Measure_Content
     (W : Meter_Widget) return Adi.Core.Size_2D;

private

   type Meter_Widget is new Adi.Widget.Box.Box_Widget with record
      Value : Fraction := 0.0;
   end record;

   package Meters is new Adi.Widget.Extension (Meter_Widget);

   type Meter_Handle is record
      Ref : Meters.Handle := Meters.Null_Handle;
   end record;

end Demo.Meter;
