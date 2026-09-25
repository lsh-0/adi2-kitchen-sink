pragma Ada_2022;

with Adi.CSS_Styles;     use Adi.CSS_Styles;
with Adi.OS;
with Adi.Widget;         use Adi.Widget;
with Adi.Widget.Box;
with Adi.Widget.Button;
with Adi.Widget.Label;
with Adi.Widget_Styles;  use Adi.Widget_Styles;

with Styling_Page_UI;    use Styling_Page_UI;

with Demo.Colours;
with Demo.Paths;
with Demo.Properties;
with Demo.Status;
with Demo.Theme;
with Demo.UI;

package body Demo.Pages.Styling is

   package Page renames Demo.UI.Styling_Page;

   use type Adi.Widget.Box.Box_Handle;
   use type Adi.Widget.Button.Button_Handle;
   use type Adi.Widget.Label.Label_Handle;

   --  Created in Ada and never bound to a stylesheet, so the style set
   --  below is the only one it has and no reload replaces it.
   Swatch : Adi.Widget.Box.Box_Handle;

   Hue    : Float := 220.0;
   Corner : Float := 16.0;

   procedure Paint_Swatch is
      C : constant Demo.Colours.RGB := Demo.Colours.From_HSV (Hue, 0.65, 0.95);
      R : constant Natural := Natural (C.R);
      G : constant Natural := Natural (C.G);
      B : constant Natural := Natural (C.B);
   begin
      Set_Part_Style
        (+Swatch, Main_Part,
         Style_Of
           .Width (Size (Px (132.0)))
           .Height (Size (Px (96.0)))
           .Background (RGB (R, G, B))
           .Radius (Radius (Px (Corner)))
           .Box_Shadow
              (Shadow (Px (0.0), Px (8.0), Px (22.0), Px (0.0),
                       RGBA (R, G, B, 0.45)))
         .Build);
   end Paint_Swatch;

   procedure On_Hue (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
   begin
      Hue := Value;
      Paint_Swatch;
   end On_Hue;

   procedure On_Radius (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
   begin
      Corner := Value;
      Paint_Swatch;
   end On_Radius;

   procedure On_Severity (W : Widget_Handle) is
      use Demo.Properties;
      Level : constant Severity_Level :=
        (if W = +Page.Set_Critical then Critical
         elsif W = +Page.Set_Warning then Warning
         else Ok);
      Message : constant String :=
        (case Level is
            when Ok       => "All systems nominal.",
            when Warning  => "Disk usage above 80 percent.",
            when Critical => "Reactor temperature out of range.");
   begin
      Severity.Set (+Page.Alert, Level);
      Adi.Widget.Label.Set_Text (Page.Alert, Message);
      Demo.Status.Report
        ("severity=""" & Severity.CSS_Name (Level) & """");
   end On_Severity;

   procedure Show_Sheet_Source is
   begin
      Adi.Widget.Label.Set_Text
        (Page.Sheet_Source,
         (if Demo.Theme.Live
          then "Watching " & Demo.Paths.Stylesheet ("")
          else "No css/ beside the binary: using the copies compiled into it."));
   end Show_Sheet_Source;

   procedure On_Reload (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Demo.Theme.Reload;
      Show_Sheet_Source;
      Demo.Status.Report ("Stylesheets reloaded");
   end On_Reload;

   procedure On_Open_CSS (W : Widget_Handle) is
      pragma Unreferenced (W);
      URL : constant String := "file://" & Demo.Paths.Stylesheet ("");
   begin
      if not Adi.OS.Open_URL (URL) then
         Demo.Status.Report ("Could not open " & URL);
      end if;
   end On_Open_CSS;

   procedure Wire is
   begin
      Page.On_Severity := On_Severity'Access;
      Page.On_Hue := On_Hue'Access;
      Page.On_Radius := On_Radius'Access;
      Page.On_Reload := On_Reload'Access;
      Page.On_Open_CSS := On_Open_CSS'Access;
   end Wire;

   procedure Start is
   begin
      Demo.Properties.Severity.Set (+Page.Alert, Demo.Properties.Ok);
      Swatch := Adi.Widget.Box.Create_Handle;
      Add_Child (+Page.Swatch_Host, +Swatch);
      Hue := Float_Slider.Get_Value (Page.Hue);
      Corner := Float_Slider.Get_Value (Page.Radius);
      Paint_Swatch;
      Show_Sheet_Source;
   end Start;

end Demo.Pages.Styling;
