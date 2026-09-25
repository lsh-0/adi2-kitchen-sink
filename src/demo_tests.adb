pragma Ada_2022;

with Ada.Command_Line;
with Ada.Text_IO;
with Interfaces;

with Demo.Colours;    use Demo.Colours;
with Demo.Elements;   use Demo.Elements;
with Demo.Frame_Policy;
with Demo.Life;       use Demo.Life;
with Demo.Proc_Stats; use Demo.Proc_Stats;
with Demo.Text;

--  Unit and property tests for the pure packages. Exits non-zero when any
--  check fails; run with `alr test` or `bin/demo_tests`.
procedure Demo_Tests is

   use type Interfaces.Unsigned_32;

   Failures : Natural := 0;
   Checks   : Natural := 0;

   procedure Check (Condition : Boolean; Name : String) is
   begin
      Checks := Checks + 1;
      if not Condition then
         Failures := Failures + 1;
         Ada.Text_IO.Put_Line ("FAIL " & Name);
      end if;
   end Check;

   procedure Check_Equal (Actual, Expected, Name : String) is
   begin
      Check (Actual = Expected,
             Name & ": expected """ & Expected & """, got """ & Actual & """");
   end Check_Equal;

   --  text -------------------------------------------------------------

   procedure Test_Text is
   begin
      Check_Equal (Demo.Text.Image (42), "42", "Image positive");
      Check_Equal (Demo.Text.Image (-7), "-7", "Image negative");
      Check_Equal (Demo.Text.Fixed (3.14159, 2), "3.14", "Fixed rounds down");
      Check_Equal (Demo.Text.Fixed (2.345, 1), "2.3", "Fixed one place");
      Check_Equal (Demo.Text.Fixed (0.05, 2), "0.05", "Fixed keeps leading zero");
      Check_Equal (Demo.Text.Fixed (-2.0, 0), "-2", "Fixed no places");
      Check_Equal (Demo.Text.Bytes (512), "512 B", "Bytes");
      Check_Equal (Demo.Text.Bytes (1536), "1.5 KiB", "KiB");
      Check_Equal (Demo.Text.Bytes (5_242_880), "5.0 MiB", "MiB");
      Check_Equal (Demo.Text.Mixed_Case ("NOBLE_GAS"), "Noble gas", "Mixed_Case");
      Check (Demo.Text.Contains ("Hydrogen", "DRO"), "Contains ignores case");
      Check (Demo.Text.Contains ("abc", ""), "Contains empty needle");
      Check (not Demo.Text.Contains ("ab", "abc"), "Contains longer needle");
      Check (Demo.Text.Count_Words ("  one two" & ASCII.LF & "three ") = 3,
             "Count_Words");
      Check (Demo.Text.Count_Lines ("") = 1, "Count_Lines empty");
      Check (Demo.Text.Count_Lines ("a" & ASCII.LF & "b") = 2, "Count_Lines");
      Check (Demo.Text.Code_Points
               ("na" & Character'Val (16#C3#) & Character'Val (16#AF#) & "ve") = 5,
             "Code_Points skips continuation bytes");
      Check_Equal (Demo.Text.Substitute ("Hello, %s.", "Ada"), "Hello, Ada.",
                   "Substitute %s");
      Check_Equal (Demo.Text.Substitute ("%d apples", "3"), "3 apples",
                   "Substitute %d");
      Check_Equal (Demo.Text.Substitute ("none", "x"), "none",
                   "Substitute without placeholder");
   end Test_Text;

   --  colours ----------------------------------------------------------

   procedure Test_Colours is
      Default : constant RGB := (1, 2, 3);
   begin
      Check (From_HSV (0.0, 1.0, 1.0) = (255, 0, 0), "HSV red");
      Check (From_HSV (120.0, 1.0, 1.0) = (0, 255, 0), "HSV green");
      Check (From_HSV (240.0, 1.0, 1.0) = (0, 0, 255), "HSV blue");
      Check (From_HSV (360.0, 1.0, 1.0) = From_HSV (0.0, 1.0, 1.0), "HSV wraps");
      Check (From_HSV (77.0, 0.0, 0.5) = (128, 128, 128), "HSV grey");
      Check (Parse_Hex ("#7ea6ff", Default) = (126, 166, 255), "hex six");
      Check (Parse_Hex ("#FFF", Default) = (255, 255, 255), "hex three");
      Check (Parse_Hex ("rgb(1,2,3)", Default) = Default, "hex rejects rgb()");
      Check (Parse_Hex ("#12345g", Default) = Default, "hex rejects non-digit");
      Check (Parse_Hex ("", Default) = Default, "hex rejects empty");
   end Test_Colours;

   --  elements ---------------------------------------------------------

   procedure Test_Elements is
   begin
      Check (Number (Hydrogen) = 1 and then Number (Xenon) = 54, "atomic numbers");
      Check_Equal (Symbol (Hydrogen), "H", "one-letter symbol");
      Check_Equal (Symbol (Helium), "He", "two-letter symbol");
      Check_Equal (Name (Iron), "Iron", "name");
      Check (Filter ("")'Length = 54, "empty filter keeps all");
      Check (Filter ("26") = [Iron], "filter by number");
      Check (Filter ("noble")'Length = 5, "filter by category");
      Check (Filter ("zzz")'Length = 0, "filter matches nothing");
      declare
         Found : constant Selection := Filter ("n");
      begin
         Check ((for all I in Found'First .. Found'Last - 1 =>
                   Number (Found (I)) < Number (Found (I + 1))),
                "filter keeps atomic-number order");
      end;
      --  property: every element matches its own symbol, name and number
      for E in Element loop
         Check (Matches (E, Symbol (E)) and then Matches (E, Name (E))
                  and then Matches (E, Demo.Text.Image (Number (E))),
                "element matches itself: " & Name (E));
      end loop;
   end Test_Elements;

   --  statm ------------------------------------------------------------

   procedure Test_Statm is
      Given    : constant String := "2000 500 100 1 0 300 0";
      Expected : constant Memory := (8_192_000, 2_048_000, 409_600);
      Actual   : constant Memory := Parse_Statm (Given);
   begin
      Check (Actual = Expected, "statm parses pages to bytes");
      Check (Parse_Statm ("12 34") = Unknown, "statm needs three fields");
      Check (Parse_Statm ("1 2 x") = Unknown, "statm rejects text");
      Check (Parse_Statm ("1 2 3", Page_Size => 1) = (1, 2, 3), "statm page size");
   end Test_Statm;

   --  frame policy -----------------------------------------------------

   procedure Test_Frame_Policy is
      use Demo.Frame_Policy;
      Given : constant Policy := (Limit => 60, Adaptive => True, Idle => 10,
                                  Linger => 1.0);
   begin
      Check (Target (Given, 0.0) = 60, "busy window runs at the limit");
      Check (Target (Given, 0.99) = 60, "limit holds through the linger");
      Check (Target (Given, 1.0) = 10, "quiet window drops to idle");
      Check (Target ((Given with delta Adaptive => False), 60.0) = 60,
             "no drop when not adaptive");
      Check (Target ((Given with delta Limit => 5), 60.0) = 5,
             "idle never exceeds the limit");
      --  property: the target is always one of the two rates, and never
      --  above the limit
      for Limit in Rate range 1 .. 120 loop
         for Tenths in 0 .. 30 loop
            declare
               P      : constant Policy := (Given with delta Limit => Limit);
               Actual : constant Rate := Target (P, Duration (Tenths) / 10);
            begin
               Check (Actual <= Limit
                        and then (Actual = Limit or else Actual = P.Idle),
                      "target bounded, limit" & Limit'Image);
            end;
         end loop;
      end loop;
      Check (Parse ("30", 60) = 30, "parse rate");
      Check (Parse ("", 60) = 60, "parse empty");
      Check (Parse ("0", 60) = 60, "parse zero");
      Check (Parse ("999", 60) = 60, "parse above range");
      Check (Parse ("3x", 60) = 60, "parse junk");
   end Test_Frame_Policy;

   --  life -------------------------------------------------------------

   function Shifted (G : Grid; Down, Right : Natural) return Grid is
   begin
      return Result : Grid := Empty do
         for R in Row loop
            for C in Column loop
               Result ((R + Down) mod Height, (C + Right) mod Width) := G (R, C);
            end loop;
         end loop;
      end return;
   end Shifted;

   procedure Test_Life is
      Block   : constant Grid := Place (Empty, [(0, 0), (0, 1), (1, 0), (1, 1)], 10, 10);
      Blinker : constant Grid := Place (Empty, [(0, 0), (0, 1), (0, 2)], 5, 5);
      Wrapped : constant Grid := Place (Empty, [(0, 0), (0, 1), (0, 2)], 0, Width - 1);
   begin
      Check (Step (Empty) = Empty, "empty stays empty");
      Check (Step (Block) = Block, "block is a still life");
      Check (Step (Blinker) /= Blinker and then Step (Step (Blinker)) = Blinker,
             "blinker has period two");
      Check (Population (Step (Blinker)) = 3, "blinker keeps three cells");
      Check (Neighbours (Wrapped, 1, 0) = 3, "neighbours wrap at the edge");
      Check (Population (Place (Empty, Glider, 0, 0)) = Glider'Length,
             "place sets every cell");

      --  a glider returns to its shape one cell down and right after four
      --  generations
      declare
         Given    : constant Grid := Place (Empty, Glider, 20, 20);
         Expected : constant Grid := Shifted (Given, 1, 1);
         Actual   : constant Grid := Step (Step (Step (Step (Given))));
      begin
         Check (Actual = Expected, "glider moves diagonally");
      end;

      --  property: on a torus the rules commute with translation
      declare
         S : Seed := 12_345;
      begin
         for Trial in 1 .. 20 loop
            S := Next (S);
            declare
               G    : constant Grid := Random (S, 30);
               Down : constant Natural := Natural (S mod Height);
               Rt   : constant Natural := Natural ((S / 7) mod Width);
            begin
               Check (Step (Shifted (G, Down, Rt)) = Shifted (Step (G), Down, Rt),
                      "step commutes with shift, trial" & Trial'Image);
            end;
         end loop;
      end;

      Check (Random (7, 50) = Random (7, 50), "random is deterministic");
      Check (Population (Random (7, 0)) = 0, "density 0 is empty");
      Check (Population (Random (7, 100)) = Width * Height, "density 100 is full");
   end Test_Life;

begin
   Test_Text;
   Test_Colours;
   Test_Elements;
   Test_Statm;
   Test_Frame_Policy;
   Test_Life;

   Ada.Text_IO.Put_Line
     (Natural'Image (Checks - Failures) & " of" & Checks'Image & " checks passed");
   if Failures > 0 then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Demo_Tests;
