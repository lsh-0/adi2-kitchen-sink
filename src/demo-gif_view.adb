pragma Ada_2022;

with Adi.Clock;

package body Demo.Gif_View is

   use Adi.Animated_Image;
   use type Adi.Image.Image_Handle;

   package Base renames Adi.Widget.Animated_Image;

   function Create_Handle return Gif_Handle is (Ref => Views.New_Widget);

   function "+" (H : Gif_Handle) return Widget_Handle is
     (Views."+" (H.Ref));

   --  Runs `Action` on the widget when `H` names one.
   procedure With_Widget
     (H      : Gif_Handle;
      Action : not null access procedure (W : in out Gif_View_Widget'Class))
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

   procedure Set_Animation (H : Gif_Handle; Animation : Animation_Handle) is
      procedure Act (W : in out Gif_View_Widget'Class) is
      begin
         Base.Set_Animation (Base.Animated_Image_Widget (W), Animation);
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Set_Animation;

   procedure Start (H : Gif_Handle) is
      procedure Act (W : in out Gif_View_Widget'Class) is
      begin
         Base.Start (Base.Animated_Image_Widget (W));
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Start;

   procedure Stop (H : Gif_Handle) is
      procedure Act (W : in out Gif_View_Widget'Class) is
      begin
         Base.Stop (Base.Animated_Image_Widget (W));
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Stop;

   procedure Set_Looping (H : Gif_Handle; Value : Boolean := True) is
      procedure Act (W : in out Gif_View_Widget'Class) is
      begin
         Base.Set_Looping (Base.Animated_Image_Widget (W), Value);
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Set_Looping;

   procedure Reset (H : Gif_Handle) is
      procedure Act (W : in out Gif_View_Widget'Class) is
      begin
         Base.Reset (Base.Animated_Image_Widget (W));
      end Act;
   begin
      With_Widget (H, Act'Access);
   end Reset;

   function Get_Animation (H : Gif_Handle) return Animation_Handle is
   begin
      if not Views.Is_Valid (H.Ref) then
         return Null_Animation_Handle;
      end if;
      declare
         R : constant Views.Ref := Views.Borrow (H.Ref);
      begin
         return Base.Get_Animation (Base.Animated_Image_Widget (R.Ptr.all));
      end;
   end Get_Animation;

   function Is_Playing (H : Gif_Handle) return Boolean is
   begin
      if not Views.Is_Valid (H.Ref) then
         return False;
      end if;
      declare
         R : constant Views.Ref := Views.Borrow (H.Ref);
      begin
         return Base.Is_Playing (Base.Animated_Image_Widget (R.Ptr.all));
      end;
   end Is_Playing;

   overriding procedure On_Tick
     (W : in out Gif_View_Widget; DT : Duration)
   is
      pragma Unreferenced (DT);
      Anim : constant Animation_Handle :=
        Base.Get_Animation (Base.Animated_Image_Widget (W));
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

end Demo.Gif_View;
