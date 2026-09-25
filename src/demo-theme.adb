pragma Ada_2022;

with Ada.Containers.Vectors;

with Adi.Assets;
with Adi.CSS_Source;   use Adi.CSS_Source;
with Adi.Log;

with App_Styles;
with Overlay_Dark_Styles;
with Overlay_Light_Styles;
with Palette_Dark_Styles;

with Demo.Paths;
with Demo.Quit_Dialog;
with Demo.UI;

package body Demo.Theme is

   use type Adi.Widget.Combo_Box.Combo_Box_Handle;
   use type Adi.Widget.Context_Menu.Menu_Handle;

   Source : aliased Style_Source;

   Active    : Theme_Kind := Dark;
   From_Disk : Boolean := False;

   package Combo_Vectors is new Ada.Containers.Vectors
     (Positive, Adi.Widget.Combo_Box.Combo_Box_Handle);
   package Menu_Vectors is new Ada.Containers.Vectors
     (Positive, Adi.Widget.Context_Menu.Menu_Handle);

   Combos : Combo_Vectors.Vector;
   Menus  : Menu_Vectors.Vector;

   Observers      : array (1 .. 8) of Observer;
   Observer_Count : Natural := 0;

   function Palette_Name (Theme : Theme_Kind) return String is
     (case Theme is
         when Dark  => "palette_dark.css",
         when Light => "palette_light.css");

   --  The palette first, so `app.css` resolves its var() references
   --  against it; both are parsed as one sheet.
   function Sheets (Theme : Theme_Kind) return Dynamic_Source_Entry_Array is
     (if From_Disk
      then [CSS_File (Paths.Stylesheet (Palette_Name (Theme))),
            CSS_File (Paths.Stylesheet ("app.css"))]
      else [CSS_Text (Adi.Assets.Get_String ("css/" & Palette_Name (Theme))),
            CSS_Text (Adi.Assets.Get_String ("css/app.css"))]);

   procedure Tick (DT : Duration) is
      pragma Unreferenced (DT);
      Reloaded, OK : Boolean;
   begin
      Tick (Source, Reloaded, OK);
      if Reloaded and then not OK then
         Adi.Log.Warning ("theme: " & Get_Last_Error (Source));
      end if;
   end Tick;

   procedure Initialize (Window : Adi.Window.Window_Handle) is
      Installed, Mode_OK : Boolean;
   begin
      From_Disk := Paths.Has_Stylesheets;
      Palette_Dark_Styles.Register_Selectors (Source);
      App_Styles.Register_Selectors (Source);
      Set_Dynamic_Sources (Source, Sheets (Dark), Installed);
      Set_Mode
        (Source, (if Installed then Dynamic_Mode else Static_Mode), Mode_OK);
      Set_Auto_Reload (Source, From_Disk);
      Adi.Window.Connect_Tick (Window, Tick'Access);
   end Initialize;

   procedure Restyle_Popups (Theme : Theme_Kind) is
      Dropdown : constant Adi.Widget.Part_Style_Array :=
        (case Theme is
            when Dark  => Overlay_Dark_Styles.Dropdown_Class_Part_Styles,
            when Light => Overlay_Light_Styles.Dropdown_Class_Part_Styles);
      Option : constant Adi.Widget.Part_Style_Array :=
        (case Theme is
            when Dark  => Overlay_Dark_Styles.Option_Class_Part_Styles,
            when Light => Overlay_Light_Styles.Option_Class_Part_Styles);
      Menu : constant Adi.Widget.Part_Style_Array :=
        (case Theme is
            when Dark  => Overlay_Dark_Styles.Menu_Class_Part_Styles,
            when Light => Overlay_Light_Styles.Menu_Class_Part_Styles);
      Item : constant Adi.Widget.Part_Style_Array :=
        (case Theme is
            when Dark  => Overlay_Dark_Styles.Menu_Item_Class_Part_Styles,
            when Light => Overlay_Light_Styles.Menu_Item_Class_Part_Styles);
   begin
      --  defaults reach popups built from now on, such as the clipboard
      --  menu a text field opens on right-click
      Adi.Widget.Combo_Box.Set_Default_Dropdown_Styles (Dropdown);
      Adi.Widget.Combo_Box.Set_Default_Option_Row_Styles (Option);
      Adi.Widget.Context_Menu.Set_Default_Menu_Styles (Menu);
      Adi.Widget.Context_Menu.Set_Default_Item_Styles (Item);

      for C of Combos loop
         Adi.Widget.Combo_Box.Set_Dropdown_Part_Styles (C, Dropdown);
         Adi.Widget.Combo_Box.Set_Option_Row_Part_Styles (C, Option);
      end loop;
      for M of Menus loop
         Adi.Widget.Context_Menu.Set_Menu_Part_Styles (M, Menu);
         Adi.Widget.Context_Menu.Set_Item_Part_Styles (M, Item);
      end loop;
   end Restyle_Popups;

   procedure Apply (Theme : Theme_Kind) is
      Set : constant Dynamic_Source_Entry_Array := Sheets (Theme);
      Failed : Natural := 0;

      procedure Check (OK : Boolean) is
      begin
         if not OK then
            Failed := Failed + 1;
         end if;
      end Check;

      OK : Boolean;
   begin
      Active := Theme;

      UI.Set_CSS_Sheets (Set, OK);               Check (OK);
      UI.Overview_Page.Set_CSS_Sheets (Set, OK); Check (OK);
      UI.Buttons_Page.Set_CSS_Sheets (Set, OK);  Check (OK);
      UI.Inputs_Page.Set_CSS_Sheets (Set, OK);   Check (OK);
      UI.Lists_Page.Set_CSS_Sheets (Set, OK);    Check (OK);
      UI.Layout_Page.Set_CSS_Sheets (Set, OK);   Check (OK);
      UI.Styling_Page.Set_CSS_Sheets (Set, OK);  Check (OK);
      UI.Media_Page.Set_CSS_Sheets (Set, OK);    Check (OK);
      UI.Document_Page.Set_CSS_Sheets (Set, OK); Check (OK);
      UI.Canvas_Page.Set_CSS_Sheets (Set, OK);   Check (OK);
      UI.System_Page.Set_CSS_Sheets (Set, OK);   Check (OK);
      Quit_Dialog.Set_CSS_Sheets (Set, OK);      Check (OK);
      Set_Dynamic_Sources (Source, Set, OK);     Check (OK);

      if Failed > 0 then
         Adi.Log.Warning
           ("theme: " & Theme'Image & " did not install in" & Failed'Image
            & " sources: " & Get_Last_Error (Source));
      end if;

      Restyle_Popups (Theme);

      for I in 1 .. Observer_Count loop
         Observers (I) (Theme);
      end loop;
   end Apply;

   function Current return Theme_Kind is (Active);

   function Live return Boolean is (From_Disk);

   procedure Reload is
   begin
      Apply (Active);
   end Reload;

   procedure Bind
     (W : Adi.Widget.Widget_Handle; Classes : String; Tag : String := "") is
   begin
      Bind_Selector_Set (Source, W, Tag_Name => Tag, Class_Name => Classes);
   end Bind;

   procedure Track (Combo : Adi.Widget.Combo_Box.Combo_Box_Handle) is
   begin
      if not Combos.Contains (Combo) then
         Combos.Append (Combo);
      end if;
   end Track;

   procedure Track (Menu : Adi.Widget.Context_Menu.Menu_Handle) is
   begin
      if not Menus.Contains (Menu) then
         Menus.Append (Menu);
      end if;
   end Track;

   function Colour (Property : String) return String is
     (if Has_Custom_Property (Source, Property)
      then Get_Custom_Property (Source, Property)
      else "");

   procedure Subscribe (Callback : not null Observer) is
   begin
      Observer_Count := Observer_Count + 1;
      Observers (Observer_Count) := Callback;
   end Subscribe;

end Demo.Theme;
