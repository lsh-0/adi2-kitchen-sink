pragma Ada_2022;

with Demo.Text;

package body Demo.Elements is

   function Name (E : Element) return String is
     (Text.Mixed_Case (E'Image));

   function Symbol (E : Element) return String is
     (if Table (E).Symbol (2) = ' '
      then Table (E).Symbol (1 .. 1)
      else Table (E).Symbol);

   function Matches (E : Element; Query : String) return Boolean is
     (Query'Length = 0
      or else Query = Text.Image (Number (E))
      or else Text.Contains (Name (E), Query)
      or else Text.Contains (Symbol (E), Query)
      or else Text.Contains (Text.Mixed_Case (Table (E).Kind'Image), Query));

   function Filter (Query : String) return Selection is
      Result : Selection (1 .. Element'Pos (Element'Last) + 1);
      Last   : Natural := 0;
   begin
      for E in Element loop
         if Matches (E, Query) then
            Last := Last + 1;
            Result (Last) := E;
         end if;
      end loop;
      return Result (1 .. Last);
   end Filter;

end Demo.Elements;
