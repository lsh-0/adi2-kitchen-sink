pragma Ada_2022;

with Adi.Image;
with Adi.RLottie;
with Adi.Widget;          use Adi.Widget;
with Adi.Widget.Extension;
with Adi.Widget.RLottie;

--  `Adi.Widget.RLottie` with a cheaper frame: a new animation frame marks
--  the widget for redrawing only. The library's widget marks it dirty,
--  which relays out and re-measures the text of every ancestor on every
--  frame, although a frame never changes the widget's size. A resize still
--  lays out as usual, which is where the animation is rasterised at its
--  new extent. `ui/widgets_extra.xml` registers it as `<lottie-view>`.
package Demo.Lottie_View is

   type Lottie_View_Widget is new Adi.Widget.RLottie.RLottie_Widget
     with private;

   type Lottie_Handle is private;

   function Create_Handle return Lottie_Handle;
   function "+" (H : Lottie_Handle) return Widget_Handle;

   procedure Set_Animation
     (H : Lottie_Handle; Animation : Adi.RLottie.Animation_Handle);
   procedure Start (H : Lottie_Handle);
   procedure Stop (H : Lottie_Handle);
   procedure Set_Looping (H : Lottie_Handle; Value : Boolean := True);
   procedure Set_Playback_Speed (H : Lottie_Handle; Multiplier : Float);
   --  Each does nothing for a stale handle.

   overriding procedure On_Tick
     (W : in out Lottie_View_Widget; DT : Duration);

private

   type Lottie_View_Widget is new Adi.Widget.RLottie.RLottie_Widget with record
      Shown : Adi.Image.Image_Handle := Adi.Image.Null_Image_Handle;
      --  The frame last asked for; the base type keeps its own copy
      --  private.
   end record;

   package Views is new Adi.Widget.Extension (Lottie_View_Widget);

   type Lottie_Handle is record
      Ref : Views.Handle := Views.Null_Handle;
   end record;

end Demo.Lottie_View;
