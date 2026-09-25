pragma Ada_2022;

with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;

with Adi.Core;
with Adi.I18N;
with Adi.OS;
with Adi.Widget;               use Adi.Widget;
with Adi.Widget.Box;
with Adi.Widget.Button;
with Adi.Widget.Button.Switch;
with Adi.Widget.Combo_Box;
with Adi.Widget.Context_Menu;
with Adi.Widget.Dialog;        use Adi.Widget.Dialog;
with Adi.Widget.Label;
with Adi.Widget.Text_Input;

with System_Page_UI;           use System_Page_UI;

with Demo.Frame_Policy;
with Demo.Pacing;
with Demo.Preferences;
with Demo.Quitting;
with Demo.Status;
with Demo.Text;
with Demo.Theme;
with Demo.UI;

package body Demo.Pages.System is

   package Page renames Demo.UI.System_Page;
   package Menus renames Adi.Widget.Context_Menu;

   use type Adi.Widget.Box.Box_Handle;
   use type Adi.Widget.Button.Button_Handle;
   use type Adi.Widget.Label.Label_Handle;
   use type Adi.Widget.Text_Input.Text_Input_Handle;

   Host   : Adi.Window.Window_Handle;
   Alert  : Dialog_Handle;
   Choice : Dialog_Handle;
   Rename : Dialog_Handle;
   Menu   : Menus.Menu_Handle;

   New_Name : Adi.Widget.Text_Input.Text_Input_Handle;

   --  dialogs ----------------------------------------------------------

   --  Binds the parts a dialog builds for itself to the stylesheet
   --  classes `ui/quit_dialog.xml` names for the same parts.
   procedure Style (D : Dialog_Handle; Buttons : Positive; Primary : Positive) is
   begin
      Demo.Theme.Bind (+D, "dialog-backdrop");
      Demo.Theme.Bind (+Get_Content_Panel_Handle (D), "dialog-panel");
      Demo.Theme.Bind (+Get_Title_Handle (D), "dialog-title");
      Demo.Theme.Bind (+Get_Message_Handle (D), "dialog-message");
      Demo.Theme.Bind (+Get_Button_Row_Handle (D), "dialog-buttons");
      for I in 1 .. Buttons loop
         Demo.Theme.Bind
           (+Get_Button_Handle (D, I),
            (if I = Primary then "dialog-btn dialog-btn-primary" else "dialog-btn"));
      end loop;
   end Style;

   procedure On_Dialog_Result
     (W : Widget_Handle; Button_Index : Natural; Button_Text : String)
   is
      Answer : constant String :=
        (if Button_Index = 0 then "dismissed" else """" & Button_Text & """");
   begin
      if W = +Rename and then Button_Index = 2 then
         Adi.Widget.Label.Set_Text
           (Page.Dialog_Result,
            "Renamed to """ & Adi.Widget.Text_Input.Get_Text (New_Name) & """");
      else
         Adi.Widget.Label.Set_Text (Page.Dialog_Result, "Answer: " & Answer);
      end if;
      Demo.Status.Report ("Dialog closed: " & Answer);
   end On_Dialog_Result;

   procedure On_Alert (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Show (Alert);
   end On_Alert;

   procedure On_Confirm (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Show (Choice);
   end On_Confirm;

   procedure On_Custom_Dialog (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Show (Rename);
   end On_Custom_Dialog;

   procedure On_Quit_Dialog (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Demo.Quitting.Ask;
   end On_Quit_Dialog;

   function Make_Dialog (Title, Message : String) return Dialog_Handle is
      D : constant Dialog_Handle := Create_Handle;
   begin
      Attach_Window (D, Host);
      Set_Title (D, Title);
      Set_Message (D, Message);
      Set_Dismiss_On_Escape (D);
      Set_Dismiss_On_Backdrop (D);
      Connect_Result (D, On_Dialog_Result'Access);
      return D;
   end Make_Dialog;

   procedure Build_Dialogs is
      Content : constant Adi.Widget.Box.Box_Handle := Adi.Widget.Box.Create_Handle;
   begin
      Alert := Make_Dialog
        ("Alert", "An alert has one button. Escape or a click on the backdrop also closes it.");
      Set_OK_Button (Alert);
      Style (Alert, Buttons => 1, Primary => 1);

      Choice := Make_Dialog
        ("Save changes?", "The document has unsaved changes.");
      Set_Yes_No_Cancel (Choice);
      Style (Choice, Buttons => 3, Primary => 3);

      Rename := Make_Dialog
        ("Rename", "Any widget tree can be a dialog's content.");
      New_Name := Adi.Widget.Text_Input.Create_Handle ("untitled.adb", "New name");
      Demo.Theme.Bind (+New_Name, "field", Tag => "text-input");
      Demo.Theme.Bind (+Content, "stack-col");
      Add_Child (+Content, +New_Name);
      Set_Content (Rename, +Content);
      Add_Button (Rename, "Cancel");
      Add_Button (Rename, "Rename");
      Set_Default_Button (Rename, 2);
      Style (Rename, Buttons => 2, Primary => 2);
   end Build_Dialogs;

   --  context menu -----------------------------------------------------

   Paste_Item : constant := 2;

   procedure On_Context (W : Widget_Handle; X, Y : Adi.Core.Pixel_Type) is
      pragma Unreferenced (W);
   begin
      Menus.Set_Item_Disabled (Menu, Paste_Item, not Adi.OS.Has_Clipboard_Text);
      Menus.Show_At (Menu, X, Y);
   end On_Context;

   procedure On_Menu_Item (M : Menus.Menu_Handle; Index : Positive; Item : String) is
      pragma Unreferenced (M);
   begin
      Adi.Widget.Label.Set_Text
        (Page.Menu_Result, "Chose """ & Item & """ (item" & Index'Image & ")");
      Demo.Status.Report ("Menu: " & Item);
   end On_Menu_Item;

   procedure Build_Menu is
   begin
      Menu := Menus.Create_Handle;
      Menus.Attach_Window (Menu, Host);
      Menus.Add_Item (Menu, "Copy");
      Menus.Add_Item (Menu, "Paste");
      Menus.Add_Item (Menu, "Rename");
      Menus.Add_Item (Menu, "Delete");
      Menus.Add_Item (Menu, "Properties");
      Menus.Connect_Item_Selected (Menu, On_Menu_Item'Access);
      Connect_Context_Menu (+Page.Menu_Target, On_Context'Access);
      Demo.Theme.Track (Menu);
   end Build_Menu;

   --  operating system -------------------------------------------------

   procedure On_Files (Files : Adi.OS.String_Array) is
   begin
      Adi.Widget.Label.Set_Text
        (Page.File_Result,
         (if Files'Length = 0 then "Cancelled."
          elsif Files'Length = 1 then To_String (Files (Files'First))
          else To_String (Files (Files'First)) & " and"
               & Natural'Image (Files'Length - 1) & " more"));
   end On_Files;

   Filters : constant Adi.OS.File_Filter_Array :=
     [(To_Unbounded_String ("Ada sources"), To_Unbounded_String ("adb;ads")),
      (To_Unbounded_String ("Stylesheets"), To_Unbounded_String ("css")),
      (To_Unbounded_String ("All files"), To_Unbounded_String ("*"))];

   procedure On_Open_File (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Adi.OS.Show_Open_File_Dialog
        (On_Files'Access, Host, Filters, Allow_Many => True);
   end On_Open_File;

   procedure On_Save_File (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Adi.OS.Show_Save_File_Dialog (On_Files'Access, Host, Filters);
   end On_Save_File;

   procedure On_Open_Folder (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      Adi.OS.Show_Open_Folder_Dialog (On_Files'Access, Host);
   end On_Open_Folder;

   procedure On_Open_URL (W : Widget_Handle) is
      pragma Unreferenced (W);
      URL : constant String := "https://github.com/ovenpasta/adi2";
   begin
      Adi.Widget.Label.Set_Text
        (Page.File_Result,
         (if Adi.OS.Open_URL (URL) then "Opened " & URL
          else "The system refused to open " & URL));
   end On_Open_URL;

   --  preferences ------------------------------------------------------

   procedure Update (Change : not null access procedure
                       (V : in out Demo.Preferences.Values))
   is
      V : Demo.Preferences.Values := Demo.Preferences.Get;
   begin
      Change (V);
      Demo.Preferences.Set (V);
   end Update;

   procedure Preview_Language (Lang : Demo.Preferences.Language) is
      Code_Text : constant String := Demo.Preferences.Code (Lang);
   begin
      Adi.Widget.Label.Set_Text
        (Page.Language_Preview,
         Adi.I18N.TL (Code_Text, "Overview") & ", "
         & Adi.I18N.TL (Code_Text, "Preferences") & ", "
         & Text.Substitute
             (Adi.I18N.TnL (Code_Text, "%d apple", "%d apples", 2), "2")
         & (if Code_Text = Adi.I18N.Get_Language then ""
            else "  (restart to switch the window)"));
   end Preview_Language;

   procedure On_Language (W : Widget_Handle; Index : Natural; Choice_Text : String) is
      pragma Unreferenced (W);
      use Demo.Preferences;
      Lang : constant Language :=
        (if Index in 1 .. Language'Pos (Language'Last) + 1
         then Language'Val (Index - 1) else English);

      procedure Store (V : in out Values) is
      begin
         V.Lang := Lang;
      end Store;
   begin
      Update (Store'Access);
      Preview_Language (Lang);
      Demo.Status.Report ("Language: " & Choice_Text);
   end On_Language;

   procedure On_UI_Scale (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
      procedure Store (V : in out Demo.Preferences.Values) is
      begin
         V.UI_Scale := Value;
      end Store;
   begin
      Adi.Window.Set_UI_Scale (Host, Adi.Core.Pixel_Type (Value));
      Update (Store'Access);
   end On_UI_Scale;

   procedure On_Text_Scale (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
      procedure Store (V : in out Demo.Preferences.Values) is
      begin
         V.Text_Scale := Value;
      end Store;
   begin
      Adi.Window.Set_Text_Scale (Host, Adi.Core.Pixel_Type (Value));
      Update (Store'Access);
   end On_Text_Scale;

   procedure On_Fullscreen (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      Adi.Window.Set_Fullscreen (Host, Active);
   end On_Fullscreen;

   procedure Toggle_Fullscreen is
      Target : constant Boolean := not Adi.Window.Is_Fullscreen (Host);
   begin
      Adi.Window.Set_Fullscreen (Host, Target);
      Adi.Widget.Button.Switch.Set_Checked (Page.Fullscreen, Target);
   end Toggle_Fullscreen;

   procedure On_Frame_Stats (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      Adi.Window.Set_Debug_Stats (Host, Active);
   end On_Frame_Stats;

   procedure On_Layout_Overlay (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      Set_Debug_Layout_Overlay_Enabled (Active);
      Adi.Window.Request_Redraw (Host);
   end On_Layout_Overlay;

   procedure On_Confirm_Quit (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
      procedure Store (V : in out Demo.Preferences.Values) is
      begin
         V.Confirm_Quit := Active;
      end Store;
   begin
      Update (Store'Access);
   end On_Confirm_Quit;

   --  Choices in the order of the combo's items.
   Limits : constant array (Positive range 1 .. 3) of Demo.Frame_Policy.Rate :=
     [60, 30, 20];

   procedure Apply_Pacing (V : Demo.Preferences.Values) is
      P : Demo.Frame_Policy.Policy := Demo.Pacing.Get_Policy;
   begin
      P.Limit := V.Frame_Limit;
      P.Adaptive := V.Idle_Drop;
      Demo.Pacing.Set_Policy (P);
   end Apply_Pacing;

   procedure On_Frame_Limit (W : Widget_Handle; Index : Natural; Choice_Text : String) is
      pragma Unreferenced (W);
      procedure Store (V : in out Demo.Preferences.Values) is
      begin
         V.Frame_Limit := (if Index in Limits'Range then Limits (Index) else 60);
      end Store;
   begin
      Update (Store'Access);
      Apply_Pacing (Demo.Preferences.Get);
      Demo.Status.Report ("Frame rate limit: " & Choice_Text);
   end On_Frame_Limit;

   procedure On_Idle_Drop (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
      procedure Store (V : in out Demo.Preferences.Values) is
      begin
         V.Idle_Drop := Active;
      end Store;
   begin
      Update (Store'Access);
      Apply_Pacing (Demo.Preferences.Get);
   end On_Idle_Drop;

   --  One process-wide switch: it covers every scroll container, pages,
   --  lists and the text editor alike.
   procedure On_Momentum (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
      procedure Store (V : in out Demo.Preferences.Values) is
      begin
         V.Momentum := Active;
      end Store;
   begin
      Set_Scroll_Inertia_Enabled (Active);
      Update (Store'Access);
      Demo.Status.Report
        ("Momentum scrolling " & (if Active then "on" else "off"));
   end On_Momentum;

   procedure Wire is
   begin
      Page.On_Momentum := On_Momentum'Access;
      Page.On_Frame_Limit := On_Frame_Limit'Access;
      Page.On_Idle_Drop := On_Idle_Drop'Access;
      Page.On_Alert := On_Alert'Access;
      Page.On_Confirm := On_Confirm'Access;
      Page.On_Custom_Dialog := On_Custom_Dialog'Access;
      Page.On_Quit_Dialog := On_Quit_Dialog'Access;
      Page.On_Open_File := On_Open_File'Access;
      Page.On_Save_File := On_Save_File'Access;
      Page.On_Open_Folder := On_Open_Folder'Access;
      Page.On_Open_URL := On_Open_URL'Access;
      Page.On_Language := On_Language'Access;
      Page.On_UI_Scale := On_UI_Scale'Access;
      Page.On_Text_Scale := On_Text_Scale'Access;
      Page.On_Fullscreen := On_Fullscreen'Access;
      Page.On_Frame_Stats := On_Frame_Stats'Access;
      Page.On_Layout_Overlay := On_Layout_Overlay'Access;
      Page.On_Confirm_Quit := On_Confirm_Quit'Access;
   end Wire;

   procedure Start (Window : Adi.Window.Window_Handle) is
      Prefs : constant Demo.Preferences.Values := Demo.Preferences.Get;
      LF    : constant Character := ASCII.LF;
   begin
      Host := Window;
      Build_Dialogs;
      Build_Menu;

      Float_Slider.Set_Step (Page.UI_Scale, 0.1);
      Float_Slider.Set_Step (Page.Text_Scale, 0.1);
      Float_Slider.Set_Value (Page.UI_Scale, Prefs.UI_Scale);
      Float_Slider.Set_Value (Page.Text_Scale, Prefs.Text_Scale);
      Adi.Window.Set_UI_Scale (Window, Adi.Core.Pixel_Type (Prefs.UI_Scale));
      Adi.Window.Set_Text_Scale (Window, Adi.Core.Pixel_Type (Prefs.Text_Scale));
      Adi.Widget.Button.Switch.Set_Checked (Page.Confirm_Quit, Prefs.Confirm_Quit);

      Demo.Theme.Track (Page.Language);
      Demo.Theme.Track (Page.Frame_Limit);
      Adi.Widget.Button.Switch.Set_Checked (Page.Idle_Drop, Prefs.Idle_Drop);
      Adi.Widget.Button.Switch.Set_Checked (Page.Momentum, Prefs.Momentum);
      Set_Scroll_Inertia_Enabled (Prefs.Momentum);
      for I in Limits'Range loop
         if Limits (I) = Prefs.Frame_Limit then
            Adi.Widget.Combo_Box.Set_Selected_Index (Page.Frame_Limit, I);
         end if;
      end loop;
      Adi.Widget.Combo_Box.Set_Selected_Index
        (Page.Language, Demo.Preferences.Language'Pos (Prefs.Lang) + 1);
      Preview_Language (Prefs.Lang);

      Adi.Widget.Label.Set_Text
        (Page.Folders,
         "home       " & Adi.OS.Get_User_Folder (Adi.OS.Home) & LF
         & "documents  " & Adi.OS.Get_User_Folder (Adi.OS.Documents) & LF
         & "executable " & Adi.OS.Base_Path);
      Adi.Widget.Label.Set_Text
        (Page.Settings_Path, "Saved to " & Demo.Preferences.File_Path);
   end Start;

end Demo.Pages.System;
