pragma Ada_2022;

package body Demo.Life is

   use type Interfaces.Unsigned_32;

   function Population (G : Grid) return Natural is
      Count : Natural := 0;
   begin
      for Cell of G loop
         if Cell then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Population;

   function Neighbours (G : Grid; R : Row; C : Column) return Natural is
      Count : Natural := 0;
   begin
      for DR in -1 .. 1 loop
         for DC in -1 .. 1 loop
            if (DR /= 0 or else DC /= 0)
              and then G ((R + DR) mod Height, (C + DC) mod Width)
            then
               Count := Count + 1;
            end if;
         end loop;
      end loop;
      return Count;
   end Neighbours;

   function Step (G : Grid) return Grid is
   begin
      return Result : Grid do
         for R in Row loop
            for C in Column loop
               Result (R, C) :=
                 (case Neighbours (G, R, C) is
                     when 3      => True,
                     when 2      => G (R, C),
                     when others => False);
            end loop;
         end loop;
      end return;
   end Step;

   function Place
     (G : Grid; P : Pattern; Top : Row; Left : Column) return Grid is
   begin
      return Result : Grid := G do
         for O of P loop
            Result ((Top + O.Down) mod Height, (Left + O.Right) mod Width) :=
              True;
         end loop;
      end return;
   end Place;

   function Next (S : Seed) return Seed is
      X : Interfaces.Unsigned_32 := S;
   begin
      X := X xor Interfaces.Shift_Left (X, 13);
      X := X xor Interfaces.Shift_Right (X, 17);
      X := X xor Interfaces.Shift_Left (X, 5);
      return X;
   end Next;

   function Random (S : Seed; Density : Percent) return Grid is
      State : Seed := S;
   begin
      return Result : Grid do
         for Cell of Result loop
            State := Next (State);
            Cell := Natural (State mod 100) < Density;
         end loop;
      end return;
   end Random;

   procedure Render (G : Grid; Live, Dead, Gap : Colour; Into : out Image) is
   begin
      for Y in Into'Range (1) loop
         for X in Into'Range (2) loop
            Into (Y, X) :=
              (if Y mod Cell_Size = Cell_Size - 1
                 or else X mod Cell_Size = Cell_Size - 1
               then Gap
               elsif G (Y / Cell_Size, X / Cell_Size) then Live
               else Dead);
         end loop;
      end loop;
   end Render;

end Demo.Life;
