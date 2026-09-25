pragma Ada_2022;

package body Demo.Proc_Stats is

   function Parse_Statm
     (Line : String; Page_Size : Positive := 4096) return Memory
   is
      Fields : array (1 .. 3) of Long_Long_Integer := [others => 0];
      Found  : Natural := 0;
      In_Num : Boolean := False;
   begin
      for Ch of Line loop
         if Ch in '0' .. '9' then
            if not In_Num then
               exit when Found = Fields'Last;
               Found := Found + 1;
               In_Num := True;
            end if;
            Fields (Found) :=
              Fields (Found) * 10 + (Character'Pos (Ch) - Character'Pos ('0'));
         elsif Ch = ' ' then
            In_Num := False;
         else
            return Unknown;
         end if;
      end loop;

      if Found < Fields'Last then
         return Unknown;
      end if;
      return (Virtual  => Fields (1) * Long_Long_Integer (Page_Size),
              Resident => Fields (2) * Long_Long_Integer (Page_Size),
              Shared   => Fields (3) * Long_Long_Integer (Page_Size));
   end Parse_Statm;

end Demo.Proc_Stats;
