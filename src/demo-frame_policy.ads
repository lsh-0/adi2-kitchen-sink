pragma Ada_2022;

--  When to run the event loop fast and when to let it idle. adi2's loop
--  wakes at a fixed rate whether or not anything changed, so the rate is
--  what an idle window costs; this chooses it from how long the window has
--  gone without drawing.
package Demo.Frame_Policy with Pure is

   subtype Rate is Positive range 1 .. 240;

   type Policy is record
      Limit    : Rate     := 60;
      --  Frames per second while anything is drawing.
      Adaptive : Boolean  := True;
      --  Drop to `Idle` once nothing has drawn for `Linger`.
      Idle     : Rate     := 10;
      Linger   : Duration := 1.0;
   end record;

   function Target (P : Policy; Quiet_For : Duration) return Rate is
     (if P.Adaptive and then Quiet_For >= P.Linger
      then Rate'Min (P.Idle, P.Limit)
      else P.Limit);
   --  The rate for a window that has not drawn for `Quiet_For`: 0.1 s ->
   --  `Limit`, 2.0 s -> `Idle`. `Idle` never exceeds `Limit`. `Linger`
   --  spans the pauses in typing or pointing, which would otherwise wait
   --  up to one idle frame for their next event.

   function Parse (Text : String; Default : Rate) return Rate;
   --  Reads a decimal rate: "30" -> 30. Returns `Default` for anything
   --  that is not a whole number in `Rate`.

end Demo.Frame_Policy;
