pragma Ada_2022;

with Adi.Clock;

package body Demo.Lottie_View is

   use Adi.RLottie;
   use type Adi.Image.Image_Handle;

   package Base renames Adi.Widget.RLottie;

   function Create_Handle return Lottie_Handle is (Ref => Views.New_Widget);

   function "+" (H : Lottie_Handle) return Widget_Handle is
     (Views."+" (H.Ref));

   --  Runs `Action` on the widget when `H` names one.
   procedure With_Widget
     (H      : Lottie_Handle;
      Action : not null access procedure (W : in out Lottie_View_Widget'Class))
   is
   begin
      if Views.Is_Valid (H.Ref) then
         declare
            R : constant Views.Ref := Views.Borrow (H.Ref);
         begin
            Action (R.Ptr.all);
         end;
      end if;
   end With_Widget;

   procedure Set_Animation (H : Lottie_Handle; Animation : Animation_Handle) is
      procedure Act (W : in out Lottie_View_Widget'Class) is
      begin
         Base.Set_Animation (Base.RLottie_Widget (W), Animation);
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Set_Animation;

   procedure Start (H : Lottie_Handle) is
      procedure Act (W : in out Lottie_View_Widget'Class) is
      begin
         Base.Start (Base.RLottie_Widget (W));
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Start;

   procedure Stop (H : Lottie_Handle) is
      procedure Act (W : in out Lottie_View_Widget'Class) is
      begin
         Base.Stop (Base.RLottie_Widget (W));
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Stop;

   procedure Set_Looping (H : Lottie_Handle; Value : Boolean := True) is
      procedure Act (W : in out Lottie_View_Widget'Class) is
      begin
         Base.Set_Looping (Base.RLottie_Widget (W), Value);
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Set_Looping;

   procedure Set_Playback_Speed (H : Lottie_Handle; Multiplier : Float) is
      procedure Act (W : in out Lottie_View_Widget'Class) is
      begin
         Base.Set_Playback_Speed (Base.RLottie_Widget (W), Multiplier);
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Set_Playback_Speed;

   overriding procedure On_Tick
     (W : in out Lottie_View_Widget; DT : Duration)
   is
      pragma Unreferenced (DT);
      Anim : constant Animation_Handle :=
        Base.Get_Animation (Base.RLottie_Widget (W));
   begin
      if not Is_Valid (Anim) then
         return;
      end if;
      Request_Tick (W);
      --  sampled by clock, as the base type does, so every viewer of a
      --  shared animation sees the same frame
      if Advance_At (Anim, Adi.Clock.Now)
        or else Get_Current_Image (Anim) /= W.Shown
      then
         W.Shown := Get_Current_Image (Anim);
         Mark_Render_Dirty (W);
      end if;
   end On_Tick;

end Demo.Lottie_View;
