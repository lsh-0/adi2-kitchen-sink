with Adi.App;
with Adi.I18N;
with Adi.Widget;         use Adi.Widget;
with Adi.Widget.Dialog;  use Adi.Widget.Dialog;

with Demo.Preferences;
with Demo.Quit_Dialog;

package body Demo.Quitting is

   Dialog    : Dialog_Handle;
   Confirmed : Boolean := False;

   --  `buttons="yes-no"` builds No then Yes.
   Yes_Index : constant := 2;

   procedure On_Result
     (W : Widget_Handle; Button_Index : Natural; Button_Text : String)
   is
      pragma Unreferenced (W, Button_Text);
   begin
      if Button_Index = Yes_Index then
         Confirmed := True;
         Adi.App.Request_Quit;
      end if;
   end On_Result;

   procedure On_Close_Request
     (Win : Adi.Window.Window_Handle; Allow : in out Boolean)
   is
      pragma Unreferenced (Win);
   begin
      Allow := Confirmed or else not Demo.Preferences.Get.Confirm_Quit;
      if not Allow then
         Ask;
      end if;
   end On_Close_Request;

   procedure Ask is
   begin
      if not Is_Shown (Dialog) then
         Show (Dialog);
      end if;
   end Ask;

   procedure Start (Window : Adi.Window.Window_Handle) is
   begin
      Dialog := Demo.Quit_Dialog.Build;
      Demo.Quit_Dialog.Attach_Window (Dialog, Window);
      --  the XML's title and message are not wrapped for translation
      Set_Title (Dialog, Adi.I18N.T ("Quit?"));
      Set_Message
        (Dialog,
         Adi.I18N.T ("Close the kitchen sink? Your preferences are already saved."));
      Connect_Result (Dialog, On_Result'Access);
      Adi.Window.Connect_Close_Request (Window, On_Close_Request'Access);
   end Start;

end Demo.Quitting;
