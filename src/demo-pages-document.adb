pragma Ada_2022;

with Adi.Assets;
with Adi.Core;
with Adi.Image;
with Adi.OS;
with Adi.Widget;           use Adi.Widget;
with Adi.Widget.Html_View; use Adi.Widget.Html_View;
with Adi.Widget.Label;

with Demo.Status;
with Demo.Text;
with Demo.Theme;
with Demo.UI;

package body Demo.Pages.Document is

   package Page renames Demo.UI.Document_Page;

   --  The palette's colours as rules placed ahead of `document.css`,
   --  which sets sizes and spacing only. The view reads no palette of its
   --  own, so this is rebuilt on each theme change.
   function Palette_Rules return String is
      function V (Name : String) return String renames Demo.Theme.Colour;
   begin
      return
        "body { color: " & V ("--text") & "; }"
        & " h1, h2 { color: " & V ("--text") & "; }"
        & " a { color: " & V ("--accent") & "; text-decoration: underline; }"
        & " code, kbd { color: " & V ("--accent") & "; }"
        & " pre { background-color: " & V ("--surface-3") & "; color: "
        & V ("--text") & "; }"
        & " blockquote { color: " & V ("--text-muted") & "; border-color: "
        & V ("--accent") & "; }"
        & " mark { background-color: " & V ("--warning-soft") & "; }"
        & " hr { border-color: " & V ("--border") & "; }"
        & " .lead, .foot { color: " & V ("--text-muted") & "; }";
   end Palette_Rules;

   function Load_Image (Self : Html_View_Handle; URI : String)
     return Adi.Image.Image_Handle
   is
      pragma Unreferenced (Self);
   begin
      return Adi.Assets.Get_Image (URI);
   end Load_Image;

   function Load_Resource (Self : Html_View_Handle; URI : String) return String
   is
      pragma Unreferenced (Self);
   begin
      return Adi.Assets.Get_String (URI);
   end Load_Resource;

   procedure On_Link (Self : Html_View_Handle; Href : String) is
      pragma Unreferenced (Self);
      Web : constant Boolean :=
        Href'Length > 8 and then Href (Href'First .. Href'First + 7) = "https://";
   begin
      if Web and then Adi.OS.Open_URL (Href) then
         Adi.Widget.Label.Set_Text (Page.Link_Status, "Opened " & Href);
      else
         Adi.Widget.Label.Set_Text (Page.Link_Status, "Link clicked: " & Href);
      end if;
      Demo.Status.Report ("Link: " & Href);
   end On_Link;

   procedure On_Zoom (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
   begin
      Set_Content_Scale (Page.Doc, Adi.Core.Pixel_Type (Value));
      Demo.Status.Report ("Zoom " & Text.Fixed (Value * 100.0, 0) & "%");
   end On_Zoom;

   procedure On_Theme (Theme : Demo.Theme.Theme_Kind) is
      pragma Unreferenced (Theme);
   begin
      Set_Default_Stylesheet_String (Page.Doc, Palette_Rules);
   end On_Theme;

   procedure Wire is
   begin
      Page.On_Zoom := On_Zoom'Access;
   end Wire;

   procedure Start is
   begin
      Set_On_Load_Asset (Page.Doc, Load_Image'Access);
      Set_On_Load_Resource (Page.Doc, Load_Resource'Access);
      Connect_Link_Click (Page.Doc, On_Link'Access);
      Set_Default_Stylesheet_String (Page.Doc, Palette_Rules);
      Set_HTML (Page.Doc, Adi.Assets.Get_String ("document.html"));
      Demo.Theme.Subscribe (On_Theme'Access);
   end Start;

end Demo.Pages.Document;
