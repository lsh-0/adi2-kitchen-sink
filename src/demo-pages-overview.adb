pragma Ada_2022;

with Ada.Text_IO;

with Adi.I18N;
with Adi.RLottie;
with Adi.Widget;          use Adi.Widget;
with Adi.Widget.Button;
with Adi.Widget.Label;

with Overview_Page_UI;

with Demo.Pacing;
with Demo.Lottie_View;
with Demo.Paths;
with Demo.Proc_Stats;
with Demo.Text;
with Demo.UI;

package body Demo.Pages.Overview is

   package Page renames Demo.UI.Overview_Page;

   type Emoji is range 1 .. 6;

   function File (E : Emoji) return String is
     (case E is
         when 1 => "noto_party_popper.json",
         when 2 => "noto_rocket.json",
         when 3 => "noto_red_heart.json",
         when 4 => "noto_star.json",
         when 5 => "noto_fire.json",
         when 6 => "noto_thumbs_up.json");

   Animations : array (Emoji) of Adi.RLottie.Animation_Handle;
   Playing    : Boolean := True;
   Visible    : Boolean := True;

   Host        : Adi.Window.Window_Handle;
   Since_Draw  : Duration := 0.0;
   Uptime      : Duration := 0.0;

   function Slot (E : Emoji) return Demo.Lottie_View.Lottie_Handle is
     (case E is
         when 1 => Page.Emoji_1, when 2 => Page.Emoji_2,
         when 3 => Page.Emoji_3, when 4 => Page.Emoji_4,
         when 5 => Page.Emoji_5, when 6 => Page.Emoji_6);

   --  `/proc/self/statm` exists on Linux only; elsewhere the figure reads
   --  as unknown.
   function Memory return Demo.Proc_Stats.Memory is
      use Ada.Text_IO;
      F : File_Type;
   begin
      Open (F, In_File, "/proc/self/statm");
      return M : constant Demo.Proc_Stats.Memory :=
        Demo.Proc_Stats.Parse_Statm (Get_Line (F))
      do
         Close (F);
      end return;
   exception
      when Name_Error | Use_Error | End_Error =>
         if Is_Open (F) then
            Close (F);
         end if;
         return Demo.Proc_Stats.Unknown;
   end Memory;

   --  Widgets reachable from `W`, `W` included.
   function Count_Widgets (W : Widget_Handle) return Natural is
      Total : Natural := (if Is_Valid (W) then 1 else 0);
   begin
      for I in 1 .. Child_Count (W) loop
         Total := Total + Count_Widgets (Get_Child_Handle (W, I));
      end loop;
      return Total;
   end Count_Widgets;

   function Clock_Image (D : Duration) return String is
      S : constant Natural := Natural (Float'Floor (Float (D)));
      Two : constant array (0 .. 9) of Character := "0123456789";
      Sec : constant Natural := S mod 60;
   begin
      return Text.Image (S / 60) & ":" & Two (Sec / 10) & Two (Sec mod 10);
   end Clock_Image;

   --  Rewrites the readouts. Every label change relays out the window, so
   --  the page's cards are rewritten only while it is showing, and neither
   --  counts as activity that keeps the loop at full rate.
   procedure Refresh is
      use type Demo.Proc_Stats.Memory;
      M     : constant Demo.Proc_Stats.Memory := Memory;
      Stats : constant Adi.Window.Frame_Stats := Adi.Window.Get_Frame_Stats (Host);
      Frame_Ms : constant Float := Float (Stats.Render_Us) / 1000.0;
      FPS   : constant Float :=
        (if Stats.Last_DT > 0.0 then 1.0 / Float (Stats.Last_DT) else 0.0);
      Widgets : constant Natural :=
        Count_Widgets (Adi.Window.Get_Root_Handle (Host));
      Resident : constant String :=
        (if M = Demo.Proc_Stats.Unknown then "n/a"
         else Text.Bytes (M.Resident));
   begin
      Demo.Pacing.Expect_Quiet_Draw;
      Adi.Widget.Label.Set_Text
        (Demo.UI.Stats,
         Resident & " resident | " & Text.Image (Widgets) & " widgets | loop at"
         & Demo.Pacing.Current_Rate'Image & " fps");
      if not Visible then
         return;
      end if;

      Adi.Widget.Label.Set_Text (Page.Resident, Resident);
      Adi.Widget.Label.Set_Text
        (Page.Virtual,
         (if M = Demo.Proc_Stats.Unknown then "/proc/self/statm unavailable"
          else Text.Bytes (M.Virtual) & " virtual, "
               & Text.Bytes (M.Shared) & " shared"));
      Adi.Widget.Label.Set_Text (Page.Frame_Time, Text.Fixed (Frame_Ms, 2) & " ms");
      Adi.Widget.Label.Set_Text
        (Page.Frame_Note,
         Text.Fixed (FPS, 0) & " fps, layout " & Text.Image (Stats.Layout_Us)
         & " us, draw " & Text.Image (Stats.Draw_Us) & " us");
      Adi.Widget.Label.Set_Text (Page.Widget_Count, Text.Image (Widgets));
      Adi.Widget.Label.Set_Text (Page.Uptime, Clock_Image (Uptime));
   end Refresh;

   procedure Tick (DT : Duration) is
   begin
      Uptime := Uptime + DT;
      Since_Draw := Since_Draw + DT;
      if Since_Draw >= (if Visible then 1.0 else 2.0) then
         Since_Draw := 0.0;
         Refresh;
      end if;
   end Tick;

   procedure On_Speed (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
   begin
      for E in Emoji loop
         Demo.Lottie_View.Set_Playback_Speed (Slot (E), Value);
      end loop;
      Adi.Widget.Label.Set_Text (Page.Speed_Value, Text.Fixed (Value, 2) & "x");
   end On_Speed;

   procedure Run_Animations is
   begin
      for E in Emoji loop
         if Playing and then Visible then
            Demo.Lottie_View.Start (Slot (E));
         else
            Demo.Lottie_View.Stop (Slot (E));
         end if;
      end loop;
   end Run_Animations;

   procedure Show (Visible : Boolean) is
   begin
      Overview.Visible := Visible;
      Run_Animations;
      if Visible then
         Refresh;
      end if;
   end Show;

   procedure On_Toggle_Animations (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Playing := not Playing;
      Run_Animations;
      Adi.Widget.Button.Set_Text
        (Page.Toggle_Animations,
         Adi.I18N.T (if Playing then "Pause" else "Play"));
   end On_Toggle_Animations;

   procedure Wire is
   begin
      Page.On_Speed := On_Speed'Access;
      Page.On_Toggle_Animations := On_Toggle_Animations'Access;
   end Wire;

   procedure Start (Window : Adi.Window.Window_Handle) is
      Missing : Natural := 0;
   begin
      Host := Window;
      Overview_Page_UI.Float_Slider.Set_Step (Page.Speed, 0.25);

      for E in Emoji loop
         Animations (E) :=
           Adi.RLottie.Load_From_File (Demo.Paths.Lottie (File (E)));
         if Adi.RLottie.Is_Valid (Animations (E)) then
            Demo.Lottie_View.Set_Animation (Slot (E), Animations (E));
         else
            Missing := Missing + 1;
         end if;
      end loop;

      Adi.Widget.Label.Set_Text
        (Page.Lottie_Note,
         (if Missing = 0
          then "Six animations share one clock; each is rasterised by rlottie at the size CSS gives it."
          else Text.Image (Missing) & " animation files are missing from "
               & Demo.Paths.Lottie ("") & ". Run alr build to stage them."));
      Adi.Widget.Label.Set_Text
        (Page.Renderer,
         "renderer: " & Adi.Window.Render_Driver (Window));

      Run_Animations;
      Adi.Window.Connect_Tick (Window, Tick'Access);
      Refresh;
   end Start;

end Demo.Pages.Overview;
