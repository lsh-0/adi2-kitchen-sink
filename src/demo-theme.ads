with Adi.Widget;
with Adi.Widget.Combo_Box;
with Adi.Widget.Context_Menu;
with Adi.Window;

--  Dark and light themes across every style source in the program: the
--  one each generated UI package owns, and one here for widgets built in
--  Ada. A theme is a palette sheet installed ahead of `app.css`; the
--  sheets come from `css/` when they are on disk, so edits reload live,
--  and from the asset bundle otherwise.
package Demo.Theme is

   type Theme_Kind is (Dark, Light);

   procedure Initialize (Window : Adi.Window.Window_Handle);
   --  Installs the dark sheets into this package's source and ticks it
   --  from `Window`, so bound widgets follow edits on disk. Requires the
   --  asset bundle to be registered.

   procedure Apply (Theme : Theme_Kind);
   --  Installs `Theme` in every source, restyles the tracked popups and
   --  calls the observers. A source whose sheets fail to install keeps
   --  the ones it had; the failure is logged at WARN.

   function Current return Theme_Kind;

   function Live return Boolean;
   --  True when the sheets were read from `css/` and reload on change.

   procedure Reload;
   --  Re-reads the current theme's sheets now rather than at the next
   --  change on disk.

   procedure Bind
     (W : Adi.Widget.Widget_Handle; Classes : String; Tag : String := "");
   --  Styles a widget built in Ada from the stylesheets, as the XML
   --  generator does for its own widgets. `Classes` is space-separated.
   --  The binding lasts until the widget is destroyed.

   procedure Track (Combo : Adi.Widget.Combo_Box.Combo_Box_Handle);
   procedure Track (Menu : Adi.Widget.Context_Menu.Menu_Handle);
   --  Registers a popup owner to restyle on each `Apply`. Popups take a
   --  copy of their style when built, so a live stylesheet cannot reach
   --  them.

   function Colour (Property : String) return String;
   --  The current palette's value for a custom property: "--text" ->
   --  "#e7e9ef" in the dark theme. Empty when the palette lacks it.

   type Observer is access procedure (Theme : Theme_Kind);

   procedure Subscribe (Callback : not null Observer);
   --  Calls `Callback` after every `Apply`. Holds up to eight observers;
   --  a ninth raises `Constraint_Error`, which is a wiring defect.

end Demo.Theme;
