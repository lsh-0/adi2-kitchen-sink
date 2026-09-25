with Adi.Settings;              use Adi.Settings;
with Adi.Settings.JSON_Backend;

package body Demo.Preferences is

   Store   : Settings_Store;
   Current : Values;

   Org : constant String := "adi2";
   App : constant String := "kitchen-sink";

   function Clamp (X : Long_Float) return Scale is
     (Scale (Long_Float'Min (Long_Float (Scale'Last),
                             Long_Float'Max (Long_Float (Scale'First), X))));

   function Language_Of (Code_Text : String; Default : Language) return Language
   is
   begin
      for L in Language loop
         if Code (L) = Code_Text then
            return L;
         end if;
      end loop;
      return Default;
   end Language_Of;

   function Theme_Of
     (Name : String; Default : Demo.Theme.Theme_Kind)
      return Demo.Theme.Theme_Kind is
   begin
      for T in Demo.Theme.Theme_Kind loop
         if Demo.Theme.Theme_Kind'Image (T) = Name then
            return T;
         end if;
      end loop;
      return Default;
   end Theme_Of;

   procedure Load is
      Default : constant Values := (others => <>);
   begin
      Adi.Settings.JSON_Backend.Create_With_JSON_Backend (Store, Org, App);
      Store.Load;
      Current :=
        (Theme        => Theme_Of
                           (Store.Get_String ("ui.theme"), Default.Theme),
         Lang         => Language_Of
                           (Store.Get_String ("ui.language"), Default.Lang),
         UI_Scale     => Clamp
                           (Store.Get_Float
                              ("ui.scale", Long_Float (Default.UI_Scale))),
         Text_Scale   => Clamp
                           (Store.Get_Float
                              ("ui.text_scale",
                               Long_Float (Default.Text_Scale))),
         Confirm_Quit => Store.Get_Boolean
                           ("app.confirm_quit", Default.Confirm_Quit),
         Frame_Limit  => Demo.Frame_Policy.Rate'Max
                           (1, Demo.Frame_Policy.Rate'Min
                                 (Demo.Frame_Policy.Rate'Last,
                                  Integer (Store.Get_Integer
                                    ("app.frame_limit",
                                     Long_Integer (Default.Frame_Limit))))),
         Idle_Drop    => Store.Get_Boolean
                           ("app.idle_drop", Default.Idle_Drop),
         Momentum     => Store.Get_Boolean
                           ("ui.momentum_scrolling", Default.Momentum));
   exception
      when Constraint_Error =>
         --  a value of the wrong kind in a hand-edited file
         Current := Default;
   end Load;

   function Get return Values is (Current);

   procedure Set (V : Values) is
   begin
      Current := V;
      Store.Set ("ui.theme", Demo.Theme.Theme_Kind'Image (V.Theme));
      Store.Set ("ui.language", Code (V.Lang));
      Store.Set ("ui.scale", Long_Float (V.UI_Scale));
      Store.Set ("ui.text_scale", Long_Float (V.Text_Scale));
      Store.Set ("app.confirm_quit", V.Confirm_Quit);
      Store.Set ("app.frame_limit", Long_Integer (V.Frame_Limit));
      Store.Set ("app.idle_drop", V.Idle_Drop);
      Store.Set ("ui.momentum_scrolling", V.Momentum);
      Store.Save;
   end Set;

   function File_Path return String is (Store.File_Path);

end Demo.Preferences;
