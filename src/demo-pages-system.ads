with Adi.Window;

--  Dialogs, a context menu, native file dialogs, OS folders and the
--  persisted preferences.
package Demo.Pages.System is

   procedure Wire;

   procedure Start (Window : Adi.Window.Window_Handle);
   --  Builds the Ada-defined dialogs and the context menu, and applies
   --  the stored scales to `Window`.

   procedure Toggle_Fullscreen;
   --  Flips full screen and keeps the page's switch in step; the F11
   --  shortcut uses it.

end Demo.Pages.System;
