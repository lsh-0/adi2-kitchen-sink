pragma Ada_2022;

--  Colour arithmetic for the pages that compute colours in Ada rather
--  than take them from a stylesheet.
package Demo.Colours with Pure is

   type Channel is range 0 .. 255;

   type RGB is record
      R, G, B : Channel;
   end record;

   subtype Unit is Float range 0.0 .. 1.0;

   function From_HSV (Hue : Float; Saturation, Value : Unit) return RGB;
   --  Converts from hue in degrees, wrapped into 0 .. 360, and saturation
   --  and value in 0 .. 1: 0, 1, 1 -> (255, 0, 0); 120, 1, 1 ->
   --  (0, 255, 0).

   function Parse_Hex (Text : String; Default : RGB) return RGB;
   --  Reads "#rrggbb" or "#rgb", in either case: "#7ea6ff" ->
   --  (126, 166, 255), "#fff" -> (255, 255, 255). Returns `Default` for
   --  anything else, including the rgb() form.

end Demo.Colours;
