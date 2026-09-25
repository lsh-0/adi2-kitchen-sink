pragma Ada_2022;

with Ada.Characters.Handling;

package body Demo.Text is

   use Ada.Characters.Handling;

   function Image (N : Integer) return String is
      S : constant String := N'Image;
   begin
      return (if S (S'First) = ' ' then S (S'First + 1 .. S'Last) else S);
   end Image;

   function Fixed (X : Float; Decimals : Natural := 1) return String is
      Scale   : constant Long_Long_Integer := 10 ** Decimals;
      Scaled  : constant Long_Long_Integer :=
        Long_Long_Integer (Long_Float (X) * Long_Float (Scale));
      Whole   : constant Long_Long_Integer := abs Scaled / Scale;
      Part    : constant Long_Long_Integer := abs Scaled mod Scale;
      Sign    : constant String := (if Scaled < 0 then "-" else "");
      Digits_Image : constant String := Long_Long_Integer'Image (Scale + Part);
   begin
      --  `Scale + Part` keeps the leading zeros of the fraction: with two
      --  places, 5 becomes 105 and its last two digits "05".
      if Decimals = 0 then
         return Sign & Image (Integer (Whole));
      end if;
      return Sign & Image (Integer (Whole)) & "."
        & Digits_Image (Digits_Image'Last - Decimals + 1 .. Digits_Image'Last);
   end Fixed;

   function Bytes (N : Long_Long_Integer) return String is
      KiB : constant Float := 1024.0;
   begin
      if N < 1024 then
         return Image (Integer (N)) & " B";
      elsif Float (N) < KiB * KiB then
         return Fixed (Float (N) / KiB) & " KiB";
      elsif Float (N) < KiB * KiB * KiB then
         return Fixed (Float (N) / (KiB * KiB)) & " MiB";
      else
         return Fixed (Float (N) / (KiB * KiB * KiB)) & " GiB";
      end if;
   end Bytes;

   function Mixed_Case (S : String) return String is
   begin
      return Result : String := To_Lower (S) do
         for I in Result'Range loop
            if Result (I) = '_' then
               Result (I) := ' ';
            end if;
         end loop;
         if Result'Length > 0 then
            Result (Result'First) := To_Upper (Result (Result'First));
         end if;
      end return;
   end Mixed_Case;

   function Contains (Haystack, Needle : String) return Boolean is
      H : constant String := To_Lower (Haystack);
      N : constant String := To_Lower (Needle);
   begin
      if N'Length = 0 then
         return True;
      end if;
      for I in H'First .. H'Last - N'Length + 1 loop
         if H (I .. I + N'Length - 1) = N then
            return True;
         end if;
      end loop;
      return False;
   end Contains;

   function Count_Words (S : String) return Natural is
      Count   : Natural := 0;
      In_Word : Boolean := False;
   begin
      for Ch of S loop
         if Ch in ' ' | ASCII.HT | ASCII.LF | ASCII.CR then
            In_Word := False;
         elsif not In_Word then
            In_Word := True;
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Count_Words;

   function Count_Lines (S : String) return Natural is
      Count : Natural := 1;
   begin
      for Ch of S loop
         if Ch = ASCII.LF then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Count_Lines;

   function Code_Points (S : String) return Natural is
      Count : Natural := 0;
   begin
      for Ch of S loop
         if Character'Pos (Ch) not in 16#80# .. 16#BF# then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Code_Points;

   function Substitute (Template, Value : String) return String is
   begin
      for I in Template'First .. Template'Last - 1 loop
         if Template (I) = '%' and then Template (I + 1) in 's' | 'd' then
            return Template (Template'First .. I - 1) & Value
              & Template (I + 2 .. Template'Last);
         end if;
      end loop;
      return Template;
   end Substitute;

end Demo.Text;
