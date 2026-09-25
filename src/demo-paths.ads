--  Files the program reads beside its executable. `alr build` puts the
--  binary in `bin/`, so the crate root is one level up; resolving from
--  the executable rather than the working directory lets the demo run from
--  anywhere.
package Demo.Paths is

   function Root return String;
   --  The crate root, with a trailing separator.

   function Stylesheet (Name : String) return String;
   --  `Root & "css/" & Name`: "app.css" -> ".../adi2-demo/css/app.css".

   function Has_Stylesheets return Boolean;
   --  True when every sheet the theme installs exists on disk. When
   --  False the program uses the copies in its asset bundle and live
   --  reload is off.

   function Lottie (Name : String) return String;
   --  `Root & "share/adi2_demo/lottie/" & Name`. rlottie reads from files
   --  only, so these stay outside the bundle.

   function Font (Name : String) return String;
   --  `Root & "share/adi2_demo/fonts/" & Name`, for the font variants
   --  `Adi.Font.Register_Variant` opens by path.

end Demo.Paths;
