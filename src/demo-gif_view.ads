pragma Ada_2022;

with Adi.Image;
with Adi.Animated_Image;
with Adi.Widget;          use Adi.Widget;
with Adi.Widget.Extension;
with Adi.Widget.Animated_Image;

--  `Adi.Widget.Animated_Image` with a cheaper frame, for the reason given
--  in `Demo.Gif_View`. `ui/widgets_extra.xml` registers it as
--  `<gif-view>`.
package Demo.Gif_View is

   type Gif_View_Widget is new Adi.Widget.Animated_Image.Animated_Image_Widget
     with private;

   type Gif_Handle is private;

   function Create_Handle return Gif_Handle;
   function "+" (H : Gif_Handle) return Widget_Handle;

   procedure Set_Animation
     (H : Gif_Handle; Animation : Adi.Animated_Image.Animation_Handle);
   procedure Start (H : Gif_Handle);
   procedure Stop (H : Gif_Handle);
   procedure Set_Looping (H : Gif_Handle; Value : Boolean := True);
   procedure Reset (H : Gif_Handle);
   --  Each does nothing for a stale handle.

   function Get_Animation
     (H : Gif_Handle) return Adi.Animated_Image.Animation_Handle;
   function Is_Playing (H : Gif_Handle) return Boolean;
   --  `Null_Animation_Handle` and False for a stale handle.

   overriding procedure On_Tick
     (W : in out Gif_View_Widget; DT : Duration);

private

   type Gif_View_Widget is new Adi.Widget.Animated_Image.Animated_Image_Widget with record
      Shown : Adi.Image.Image_Handle := Adi.Image.Null_Image_Handle;
      --  The frame last asked for; the base type keeps its own copy
      --  private.
   end record;

   package Views is new Adi.Widget.Extension (Gif_View_Widget);

   type Gif_Handle is record
      Ref : Views.Handle := Views.Null_Handle;
   end record;

end Demo.Gif_View;
