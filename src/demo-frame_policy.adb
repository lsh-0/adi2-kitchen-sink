pragma Ada_2022;

package body Demo.Frame_Policy is

   function Parse (Text : String; Default : Rate) return Rate is
      Value : Natural := 0;
   begin
      if Text'Length = 0 or else Text'Length > 3 then
         return Default;
      end if;
      for Ch of Text loop
         if Ch not in '0' .. '9' then
            return Default;
         end if;
         Value := Value * 10 + (Character'Pos (Ch) - Character'Pos ('0'));
      end loop;
      return (if Value in Rate then Value else Default);
   end Parse;

end Demo.Frame_Policy;
