pragma Ada_2022;

with Adi.CSS_Styles;
with Adi.Layout_Util;
with Adi.Resolved_Styles;

package body Demo.Meter is

   use Adi.Core;

   Frame_Idx     : constant := 1;
   Track_Idx     : constant := 2;
   Indicator_Idx : constant := 3;

   function Create_Handle return Meter_Handle is (Ref => Meters.New_Widget);

   function "+" (H : Meter_Handle) return Widget_Handle is
     (Meters."+" (H.Ref));

   function Is_Valid (H : Meter_Handle) return Boolean is
     (Meters.Is_Valid (H.Ref));

   procedure Set_Value (H : Meter_Handle; Value : Fraction) is
   begin
      if not Meters.Is_Valid (H.Ref) then
         return;
      end if;
      declare
         R : constant Meters.Ref := Meters.Borrow (H.Ref);
      begin
         R.Value := Value;
      end;
      --  the size is unchanged, so the items are rebuilt without a layout
      Mark_Render_Dirty (+H);
   end Set_Value;

   function Get_Value (H : Meter_Handle) return Fraction is
   begin
      if not Meters.Is_Valid (H.Ref) then
         return 0.0;
      end if;
      declare
         R : constant Meters.Ref := Meters.Borrow (H.Ref);
      begin
         return R.Value;
      end;
   end Get_Value;

   --  The track is the content box; the indicator is its left share.
   procedure Place_Items (W : in out Meter_Widget) is
      Style : Adi.CSS_Styles.Resolved_Style renames
        Adi.Resolved_Styles.Ref (Get_Resolved_Part_Handle (W, Main_Part)).all;
      Frame : constant Rectangle := Get_Geometry (W);
      Track : constant Rectangle := Adi.Layout_Util.Content_Box (Frame, Style);
      Fill  : constant Rectangle :=
        (Track.X, Track.Y, Track.Width * Pixel_Type (W.Value), Track.Height);

      procedure Put (Index : Positive; Geometry : Rectangle) is
         I : Item := Get_Item (W, Index);
      begin
         I.Geometry := Geometry;
         Update_Item (W, Index, I);
      end Put;
   begin
      if Item_Count (W) < Indicator_Idx then
         return;
      end if;
      Put (Frame_Idx, Frame);
      Put (Track_Idx, Track);
      Put (Indicator_Idx, Fill);
   end Place_Items;

   overriding procedure Build_Items (W : in out Meter_Widget) is
   begin
      if Item_Count (W) = 0 then
         declare
            G : constant Rectangle := Get_Geometry (W);
         begin
            Add_Item (W, Make_Panel (Main_Part, G, 0));
            Add_Item (W, Make_Panel (Scroll_Part, G, 1));
            Add_Item (W, Make_Panel (Indicator_Part, G, 2));
         end;
      end if;
      Place_Items (W);
   end Build_Items;

   overriding procedure Layout (W : in out Meter_Widget) is
   begin
      Place_Items (W);
   end Layout;

   --  No text and no image: the stylesheet sets the size, as it does for
   --  the library's switch.
   overriding function Measure_Content
     (W : Meter_Widget) return Adi.Core.Size_2D is ((0.0, 0.0));

end Demo.Meter;
