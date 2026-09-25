with Ada.Directories;

with Adi.OS;

package body Demo.Paths is

   function Root return String is
      Bin : constant String := Adi.OS.Base_Path;
   begin
      return Ada.Directories.Full_Name (Bin & "..") & Adi.OS.Path_Separator;
   end Root;

   function Stylesheet (Name : String) return String is
     (Root & "css" & Adi.OS.Path_Separator & Name);

   function Has_Stylesheets return Boolean is
     (Ada.Directories.Exists (Stylesheet ("app.css"))
      and then Ada.Directories.Exists (Stylesheet ("palette_dark.css"))
      and then Ada.Directories.Exists (Stylesheet ("palette_light.css")));

   function Lottie (Name : String) return String is
     (Root & "share" & Adi.OS.Path_Separator & "adi2_demo"
      & Adi.OS.Path_Separator & "lottie" & Adi.OS.Path_Separator & Name);

   function Font (Name : String) return String is
     (Root & "share" & Adi.OS.Path_Separator & "adi2_demo"
      & Adi.OS.Path_Separator & "fonts" & Adi.OS.Path_Separator & Name);

end Demo.Paths;
