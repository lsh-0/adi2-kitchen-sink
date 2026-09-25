pragma Ada_2022;

with Ada.Command_Line;
with Ada.Directories;

with Adi.CSS_Styles;
with Adi.Assets;
with Adi.Font;
with Adi.I18N;
with Adi.Layout_Util;
with Adi.MCP;
with Adi.Window;

with Demo_Bundle;
with Demo_Translations;

with Demo.Frame_Policy;
with Demo.Pacing;
with Demo.Pages.Buttons;
with Demo.Pages.Canvas;
with Demo.Pages.Document;
with Demo.Pages.Inputs;
with Demo.Pages.Lists;
with Demo.Pages.Media;
with Demo.Pages.Overview;
with Demo.Pages.Styling;
with Demo.Pages.System;
with Demo.Paths;
with Demo.Preferences;
with Demo.Quitting;
with Demo.Shell;
with Demo.Theme;
with Demo.Text;
with Demo.UI;

with Shell_UI;

--  Usage: adi2_demo [--lang en|fr|de] [--fps N] [--page NAME] [--stats]
--  `--lang` and `--fps` override the saved preferences for this run;
--  `--page` opens on a page other than Overview, e.g. `--page canvas`;
--  `--stats` logs frame timings once a second.
procedure Adi2_Demo is
   Window : Adi.Window.Window_Handle;

   --  The value after `Flag`, or "" when it is absent.
   function Option (Flag : String) return String is
      use Ada.Command_Line;
   begin
      for I in 1 .. Argument_Count - 1 loop
         if Argument (I) = Flag then
            return Argument (I + 1);
         end if;
      end loop;
      return "";
   end Option;

   function Language_Argument return String is (Option ("--lang"));

   function Flag (Name : String) return Boolean is
     (for some I in 1 .. Ada.Command_Line.Argument_Count =>
        Ada.Command_Line.Argument (I) = Name);

begin
   Demo.Pacing.Init;
   Adi.Layout_Util.Set_Px_Maps_To_Dip (True);
   Demo.Preferences.Load;
   declare
      Prefs : constant Demo.Preferences.Values := Demo.Preferences.Get;
   begin
      Demo.Pacing.Set_Policy
        ((Limit    => Demo.Frame_Policy.Parse
                        (Option ("--fps"), Default => Prefs.Frame_Limit),
          Adaptive => Prefs.Idle_Drop,
          others   => <>));
   end;

   --  assets: everything but the Lottie files is compiled in
   Demo_Bundle.Register_All;
   Adi.Assets.Set_Mode (Adi.Assets.Bundle_Mode);
   declare
      use Adi.CSS_Styles;
      Sans : constant Font_Handle :=
        Adi.Font.Load_Asset ("OpenSans-Regular.ttf");

      --  a missing file leaves the weight or style to be synthesised
      procedure Variant
        (Weight : Font_Weight_Value; Style : Font_Style_Value; File : String)
      is
         Path : constant String := Demo.Paths.Font (File);
      begin
         if Ada.Directories.Exists (Path) then
            Adi.Font.Register_Variant (Sans, Weight, Style, Path);
         end if;
      end Variant;
   begin
      Adi.Font.Set_Default_Font (Sans);
      Variant (Weight_Semi_Bold, Style_Normal, "OpenSans-SemiBold.ttf");
      Variant (Weight_Bold, Style_Normal, "OpenSans-Bold.ttf");
      Variant (Weight_Normal, Style_Italic, "OpenSans-Italic.ttf");
      Variant (Weight_Bold, Style_Italic, "OpenSans-BoldItalic.ttf");
   end;

   --  translations are applied as the tree is built, so before `Build`
   Demo_Translations.Register_All;
   Adi.I18N.Set_Language
     (if Language_Argument /= "" then Language_Argument
      else Demo.Preferences.Code (Demo.Preferences.Get.Lang));

   Demo.Shell.Wire;
   Demo.Pages.Overview.Wire;
   Demo.Pages.Buttons.Wire;
   Demo.Pages.Inputs.Wire;
   Demo.Pages.Lists.Wire;
   Demo.Pages.Styling.Wire;
   Demo.Pages.Media.Wire;
   Demo.Pages.Document.Wire;
   Demo.Pages.Canvas.Wire;
   Demo.Pages.System.Wire;

   Window := Demo.UI.Build;
   Adi.Window.Set_Enforce_Layout_Min_Size (Window, False);

   Demo.Theme.Initialize (Window);
   Demo.Pages.Overview.Start (Window);
   Demo.Pages.Buttons.Start;
   Demo.Pages.Inputs.Start;
   Demo.Pages.Lists.Start;
   Demo.Pages.Styling.Start;
   Demo.Pages.Media.Start;
   Demo.Pages.Document.Start;
   Demo.Pages.Canvas.Start (Window);
   Demo.Pages.System.Start (Window);
   Demo.Quitting.Start (Window);
   Demo.Shell.Start (Window);

   for P in Shell_UI.Page loop
      if Demo.Text.Contains (Demo.Text.Mixed_Case (P'Image), Option ("--page"))
        and then Option ("--page") /= ""
      then
         Shell_UI.Nav_Options.Set_Selected (Demo.UI.Nav_Options_Group, P);
         exit;
      end if;
   end loop;

   --  development builds answer the MCP bridge; release builds link a stub
   Adi.MCP.Initialize (Window);
   Demo.Pacing.Log_Frames (Flag ("--stats"));
   Demo.Pacing.Run (Window);
   Adi.MCP.Finalize;
end Adi2_Demo;
