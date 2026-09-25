pragma Ada_2022;

with Adi.I18N;
with Adi.SDL.Events;           use Adi.SDL.Events;
with Adi.Widget;               use Adi.Widget;
with Adi.Widget.Button.Switch;
with Adi.Widget.Label;

with Shell_UI;                 use Shell_UI;

with Demo.Pages.Media;
with Demo.Pages.Overview;
with Demo.Pages.System;
with Demo.Preferences;
with Demo.Status;
with Demo.Text;
with Demo.Theme;               use Demo.Theme;
with Demo.UI;

package body Demo.Shell is

   SDL_SCANCODE_T   : constant SDL_Scancode := 23;
   SDL_SCANCODE_F11 : constant SDL_Scancode := 68;

   procedure On_Page (Id : Page) is
      Title : constant String := Adi.I18N.T (Text.Mixed_Case (Id'Image));
   begin
      Page_Stack.Set_Active (Demo.UI.Pages, Id);
      Demo.Pages.Overview.Show (Id = Overview);
      Demo.Pages.Media.Show (Id = Media);
      Adi.Widget.Label.Set_Text (Demo.UI.Page_Title, Title);
      Demo.Status.Report (Title);
   end On_Page;

   procedure Switch_Theme (Theme : Theme_Kind) is
      V : Demo.Preferences.Values := Demo.Preferences.Get;
   begin
      Demo.Theme.Apply (Theme);
      Adi.Widget.Button.Switch.Set_Checked (Demo.UI.Theme_Switch, Theme = Dark);
      V.Theme := Theme;
      Demo.Preferences.Set (V);
      Demo.Status.Report
        ("Theme: " & Text.Mixed_Case (Theme'Image)
         & (if Demo.Theme.Live then " (from css/, live)" else " (from the bundle)"));
   end Switch_Theme;

   procedure On_Theme (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      Switch_Theme (if Active then Dark else Light);
   end On_Theme;

   function Neighbour (P : Page; Forward : Boolean) return Page is
     (if Forward
      then (if P = Page'Last then Page'First else Page'Succ (P))
      else (if P = Page'First then Page'Last else Page'Pred (P)));

   --  Runs before the focused widget sees the key; setting `Handled`
   --  stops it there.
   procedure On_Key
     (Scancode : SDL_Scancode;
      Keycode  : SDL_Keycode;
      Key_Mod  : SDL_Keymod;
      Repeat   : Boolean;
      Handled  : in out Boolean)
   is
      pragma Unreferenced (Keycode, Repeat);
      Ctrl : constant Boolean := (Key_Mod and SDL_KMOD_CTRL) /= 0;
   begin
      if Ctrl and then Scancode in SDL_SCANCODE_PAGEUP | SDL_SCANCODE_PAGEDOWN then
         Nav_Options.Set_Selected
           (Demo.UI.Nav_Options_Group,
            Neighbour (Page_Stack.Get_Active (Demo.UI.Pages),
                       Forward => Scancode = SDL_SCANCODE_PAGEDOWN));
         Handled := True;
      elsif Ctrl and then Scancode = SDL_SCANCODE_T then
         Switch_Theme (if Demo.Theme.Current = Dark then Light else Dark);
         Handled := True;
      elsif Scancode = SDL_SCANCODE_F11 then
         Demo.Pages.System.Toggle_Fullscreen;
         Handled := True;
      end if;
   end On_Key;

   procedure Wire is
   begin
      Demo.UI.On_Page := On_Page'Access;
      Demo.UI.On_Theme := On_Theme'Access;
   end Wire;

   procedure Start (Window : Adi.Window.Window_Handle) is
      Theme : constant Theme_Kind := Demo.Preferences.Get.Theme;
   begin
      Demo.Theme.Apply (Theme);
      Adi.Widget.Button.Switch.Set_Checked (Demo.UI.Theme_Switch, Theme = Dark);
      Nav_Options.Set_Selected (Demo.UI.Nav_Options_Group, Overview);
      Adi.Window.Connect_Key_Down (Window, On_Key'Access);
      Demo.Status.Report (Adi.I18N.T ("Ready."));
   end Start;

end Demo.Shell;
