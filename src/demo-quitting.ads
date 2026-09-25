with Adi.Window;

--  Closing the window: asks first when the preference says so, using
--  the dialog declared in `ui/quit_dialog.xml`.
package Demo.Quitting is

   procedure Start (Window : Adi.Window.Window_Handle);
   --  Builds the dialog and intercepts the window's close request.

   procedure Ask;
   --  Shows the dialog. Its Yes button ends the run.

end Demo.Quitting;
