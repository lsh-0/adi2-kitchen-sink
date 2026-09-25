with Adi.App;
with Ada.Text_IO;


package body Demo.Pacing is

   use Demo.Frame_Policy;

   App    : Adi.App.App;
   Host   : Adi.Window.Window_Handle;
   Active : Policy;
   Now    : Rate := Active.Limit;

   Last_Frame  : Natural := 0;
   Quiet       : Duration := 0.0;
   Own_Drawing : Boolean := False;

   --  frame timing log
   Logging     : Boolean := False;
   Log_Elapsed : Duration := 0.0;
   Log_Frames_Drawn : Natural := 0;
   Layout_Sum, Draw_Sum, Present_Sum : Natural := 0;

   procedure Log_Tick (DT : Duration; S : Adi.Window.Frame_Stats; Drew : Boolean) is
      function Avg (Sum : Natural) return String is
        (Natural'Image (Sum / Natural'Max (1, Log_Frames_Drawn)));
   begin
      if Drew then
         Log_Frames_Drawn := Log_Frames_Drawn + 1;
         Layout_Sum := Layout_Sum + S.Layout_Us;
         Draw_Sum := Draw_Sum + S.Draw_Us;
         Present_Sum := Present_Sum + S.Present_Us;
      end if;
      Log_Elapsed := Log_Elapsed + DT;
      if Log_Elapsed >= 1.0 then
         --  standard output rather than Adi.Log, which release builds
         --  compile to nothing
         Ada.Text_IO.Put_Line
           ("frames:" & Log_Frames_Drawn'Image & " drawn, loop at" & Now'Image
            & " fps; average us: layout" & Avg (Layout_Sum)
            & ", draw" & Avg (Draw_Sum) & ", present" & Avg (Present_Sum));
         Ada.Text_IO.Flush;
         Log_Elapsed := 0.0;
         Log_Frames_Drawn := 0;
         Layout_Sum := 0;
         Draw_Sum := 0;
         Present_Sum := 0;
      end if;
   end Log_Tick;

   procedure Apply (R : Rate) is
   begin
      if R /= Now then
         Now := R;
         App.Set_Target_FPS (R);
      end if;
   end Apply;

   --  `Frame_No` counts frames that drew; an unchanged count means the
   --  window has been quiet since the last tick.
   procedure Tick (DT : Duration) is
      Stats : constant Adi.Window.Frame_Stats := Adi.Window.Get_Frame_Stats (Host);
      Frame : constant Natural := Stats.Frame_No;
   begin
      if Logging then
         Log_Tick (DT, Stats, Drew => Frame /= Last_Frame);
      end if;
      if Frame /= Last_Frame then
         Last_Frame := Frame;
         if Own_Drawing then
            Own_Drawing := False;
         else
            Quiet := 0.0;
         end if;
      else
         Quiet := Quiet + DT;
      end if;
      Apply (Target (Active, Quiet));
   end Tick;

   procedure Init is
   begin
      App.Init;
      App.Set_Target_FPS (Now);
   end Init;

   procedure Set_Policy (P : Policy) is
   begin
      Active := P;
      Quiet := 0.0;
      Apply (Target (Active, Quiet));
   end Set_Policy;

   function Get_Policy return Policy is (Active);

   procedure Expect_Quiet_Draw is
   begin
      Own_Drawing := True;
   end Expect_Quiet_Draw;

   function Current_Rate return Rate is (Now);

   procedure Log_Frames (Enabled : Boolean) is
   begin
      Logging := Enabled;
   end Log_Frames;

   procedure Run (Window : Adi.Window.Window_Handle) is
   begin
      Host := Window;
      Adi.Window.Connect_Tick (Window, Tick'Access);
      App.Add_Window (Window);
      App.Run;
   end Run;

end Demo.Pacing;
