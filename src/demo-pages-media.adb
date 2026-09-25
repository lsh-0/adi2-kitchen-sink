pragma Ada_2022;

with Adi.Animated_Image;
with Adi.Assets;
with Adi.Image;
with Adi.Widget;                 use Adi.Widget;
with Adi.Widget.Image;
with Adi.Widget.Label;

with Demo.Gif_View;
with Demo.Status;
with Demo.Text;
with Demo.UI;

package body Demo.Pages.Media is

   package Page renames Demo.UI.Media_Page;
   package Player renames Demo.Gif_View;

   --  An image handle keeps nothing alive, so the owner lives here for
   --  the whole run while the image widget draws it.
   Hexagon : Adi.Image.Image_Owner;

   Hexagon_Path : constant String := "M7 3h10l5 9-5 9H7l-5-9z";

   Wanted  : Boolean := True;
   Visible : Boolean := False;

   procedure Run is
   begin
      if Wanted and then Visible then
         Player.Start (Page.Horse);
      else
         Player.Stop (Page.Horse);
      end if;
   end Run;

   procedure Show_State is
      Anim : constant Adi.Animated_Image.Animation_Handle :=
        Player.Get_Animation (Page.Horse);
   begin
      Adi.Widget.Label.Set_Text
        (Page.Gif_State,
         (if not Adi.Animated_Image.Is_Valid (Anim)
          then "animhorse.gif is not in the bundle."
          else (if Player.Is_Playing (Page.Horse) then "Playing" else "Stopped")
               & ", frame "
               & Text.Image (Adi.Animated_Image.Get_Current_Frame_Index (Anim) + 1)
               & " of "
               & Text.Image (Adi.Animated_Image.Get_Frame_Count (Anim))));
   end Show_State;

   procedure On_Play (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Wanted := True;
      Run;
      Show_State;
   end On_Play;

   procedure On_Stop (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Wanted := False;
      Run;
      Show_State;
      Demo.Status.Report ("GIF stopped");
   end On_Stop;

   procedure On_Reset (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Player.Reset (Page.Horse);
      Show_State;
   end On_Reset;

   procedure Wire is
   begin
      Page.On_Play := On_Play'Access;
      Page.On_Stop := On_Stop'Access;
      Page.On_Reset := On_Reset'Access;
   end Wire;

   procedure Start is
   begin
      --  the asset cache owns what it hands out
      Player.Set_Animation
        (Page.Horse, Adi.Assets.Get_Animated_Image ("animhorse.gif"));
      Run;

      --  tintable: drawn white, then coloured by the widget's CSS `color`
      Hexagon := Adi.Image.Load_SVG_Path
        (Path_Data => Hexagon_Path,
         Size      => (24.0, 24.0),
         Fill      => (R => 255, G => 255, B => 255, A => 255),
         Tintable  => True);
      Adi.Widget.Image.Set_Image (Page.Path_Icon, Adi.Image.To_Handle (Hexagon));

      Show_State;
   end Start;

   procedure Show (Visible : Boolean) is
   begin
      Media.Visible := Visible;
      Run;
      Show_State;
   end Show;

end Demo.Pages.Media;
