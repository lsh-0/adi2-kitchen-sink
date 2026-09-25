pragma Ada_2022;

--  Parsing for `/proc/self/statm`, the Linux view of a process's memory.
--  Reading the file is left to the caller so this stays pure and testable.
package Demo.Proc_Stats with Pure is

   type Memory is record
      Virtual  : Long_Long_Integer := 0;
      Resident : Long_Long_Integer := 0;
      Shared   : Long_Long_Integer := 0;
   end record;
   --  Sizes in bytes.

   Unknown : constant Memory := (others => 0);

   function Parse_Statm
     (Line : String; Page_Size : Positive := 4096) return Memory;
   --  Reads the first three fields of a statm line, which count pages:
   --  "2000 500 100 ..." -> (8_192_000, 2_048_000, 409_600). Returns
   --  `Unknown` when the line holds fewer than three numbers.

end Demo.Proc_Stats;
