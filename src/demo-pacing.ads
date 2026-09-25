with Adi.Window;

with Demo.Frame_Policy;

--  The application object and the rate its loop runs at. Owning the
--  `Adi.App.App` here lets the pages change the rate at run time.
package Demo.Pacing is

   procedure Init;
   --  Starts SDL and the font stack. Call before anything else in `Adi`.

   procedure Set_Policy (P : Demo.Frame_Policy.Policy);
   --  Takes effect at the next frame.

   function Get_Policy return Demo.Frame_Policy.Policy;

   procedure Expect_Quiet_Draw;
   --  Marks the next frame the window draws as the program's own, such as
   --  a periodic readout, so it does not count as activity.

   function Current_Rate return Demo.Frame_Policy.Rate;
   --  The rate the loop is running at now, `Limit` or `Idle`.

   procedure Log_Frames (Enabled : Boolean);
   --  Writes to standard output, once a second, the frames drawn and the average
   --  layout, draw and present time per frame, from the window's own
   --  counters.

   procedure Run (Window : Adi.Window.Window_Handle);
   --  Adopts `Window`, adjusts the rate from its frame counter every tick,
   --  and runs the loop until the window closes.

end Demo.Pacing;
