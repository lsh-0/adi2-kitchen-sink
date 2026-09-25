pragma Ada_2022;

--  String formatting shared by the pages. Kept apart from the widgets so
--  the unit tests reach it without SDL.
package Demo.Text with Pure is

   function Image (N : Integer) return String;
   --  `Integer'Image` without the leading space: 42 -> "42", -7 -> "-7".

   function Fixed (X : Float; Decimals : Natural := 1) return String;
   --  Rounds to `Decimals` places without an exponent: 3.14159, 2 ->
   --  "3.14"; 0.05, 1 -> "0.1"; -2.0, 0 -> "-2".

   function Bytes (N : Long_Long_Integer) return String;
   --  Renders a byte count in binary units: 512 -> "512 B",
   --  1536 -> "1.5 KiB", 5_242_880 -> "5.0 MiB".

   function Mixed_Case (S : String) return String;
   --  Turns an enumeration image into display text: the first letter
   --  upper case, the rest lower case, `_` as a space. "NOBLE_GAS" ->
   --  "Noble gas".

   function Contains (Haystack, Needle : String) return Boolean;
   --  Case-insensitive substring test. The empty needle is in every
   --  string.

   function Count_Words (S : String) return Natural;
   --  Counts runs of characters other than space, tab and line breaks.

   function Count_Lines (S : String) return Natural;
   --  Line feeds plus one; the empty string has one line.

   function Code_Points (S : String) return Natural;
   --  Counts UTF-8 code points by skipping continuation bytes: "naïve"
   --  is 6 bytes and 5 code points.

   function Substitute (Template, Value : String) return String;
   --  Replaces the first "%s" or "%d" in `Template` with `Value`, the
   --  placeholder convention the `.po` catalogues use: "Hello, %s.",
   --  "Ada" -> "Hello, Ada.". A template without one is returned as is.

end Demo.Text;
