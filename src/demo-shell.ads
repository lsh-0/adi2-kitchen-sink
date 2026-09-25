with Adi.Window;

--  The frame around the pages: navigation, the theme switch and the
--  window-wide keyboard shortcuts.
package Demo.Shell is

   procedure Wire;

   procedure Start (Window : Adi.Window.Window_Handle);
   --  Applies the stored theme, selects the first page and installs the
   --  key hook.

end Demo.Shell;
