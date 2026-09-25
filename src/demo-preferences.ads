with Demo.Frame_Policy;
with Demo.Theme;

--  Choices that outlive a run, kept by `Adi.Settings` as JSON under the
--  per-user preferences directory SDL reports.
package Demo.Preferences is

   type Language is (English, French, German);

   function Code (L : Language) return String is
     (case L is
         when English => "en",
         when French  => "fr",
         when German  => "de");

   subtype Scale is Float range 0.5 .. 2.0;

   type Values is record
      Theme        : Demo.Theme.Theme_Kind := Demo.Theme.Dark;
      Lang         : Language := English;
      UI_Scale     : Scale := 1.0;
      Text_Scale   : Scale := 1.0;
      Confirm_Quit : Boolean := True;
      Frame_Limit  : Demo.Frame_Policy.Rate := 60;
      Idle_Drop    : Boolean := True;
      Momentum     : Boolean := True;
      --  Scrolling coasts to a stop after a wheel flick or drag. Off, a
      --  wheel notch moves the content one step at once.
   end record;

   procedure Load;
   --  Reads the settings file. A missing file, or a value of the wrong
   --  kind or out of range, leaves that field at its default.

   function Get return Values;

   procedure Set (V : Values);
   --  Replaces the values and writes the file at once, so a crash later
   --  in the run loses nothing.

   function File_Path return String;

end Demo.Preferences;
