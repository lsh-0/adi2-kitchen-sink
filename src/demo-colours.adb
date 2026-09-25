pragma Ada_2022;

package body Demo.Colours is

   function From_HSV (Hue : Float; Saturation, Value : Unit) return RGB is
      H : constant Float :=
        Hue - 360.0 * Float'Floor (Hue / 360.0);
      Sector : constant Natural := Natural (Float'Floor (H / 60.0)) mod 6;
      F : constant Float := H / 60.0 - Float'Floor (H / 60.0);
      P : constant Float := Value * (1.0 - Saturation);
      Q : constant Float := Value * (1.0 - Saturation * F);
      T : constant Float := Value * (1.0 - Saturation * (1.0 - F));

      function C (X : Float) return Channel is
        (Channel (Float'Rounding (X * 255.0)));
   begin
      return
        (case Sector is
            when 0      => (C (Value), C (T), C (P)),
            when 1      => (C (Q), C (Value), C (P)),
            when 2      => (C (P), C (Value), C (T)),
            when 3      => (C (P), C (Q), C (Value)),
            when 4      => (C (T), C (P), C (Value)),
            when others => (C (Value), C (P), C (Q)));
   end From_HSV;

   function Parse_Hex (Text : String; Default : RGB) return RGB is

      function Digit (Ch : Character) return Integer is
        (case Ch is
            when '0' .. '9' => Character'Pos (Ch) - Character'Pos ('0'),
            when 'a' .. 'f' => Character'Pos (Ch) - Character'Pos ('a') + 10,
            when 'A' .. 'F' => Character'Pos (Ch) - Character'Pos ('A') + 10,
            when others     => -1);

      function Valid (S : String) return Boolean is
        (for all Ch of S => Digit (Ch) >= 0);

      function Pair (S : String) return Channel is
        (Channel (Digit (S (S'First)) * 16 + Digit (S (S'First + 1))));

      function Single (Ch : Character) return Channel is
        (Channel (Digit (Ch) * 17));

      F : constant Positive := Text'First;
   begin
      if Text'Length = 7 and then Text (F) = '#'
        and then Valid (Text (F + 1 .. Text'Last))
      then
         return (Pair (Text (F + 1 .. F + 2)),
                 Pair (Text (F + 3 .. F + 4)),
                 Pair (Text (F + 5 .. F + 6)));
      elsif Text'Length = 4 and then Text (F) = '#'
        and then Valid (Text (F + 1 .. Text'Last))
      then
         return (Single (Text (F + 1)),
                 Single (Text (F + 2)),
                 Single (Text (F + 3)));
      else
         return Default;
      end if;
   end Parse_Hex;

end Demo.Colours;
