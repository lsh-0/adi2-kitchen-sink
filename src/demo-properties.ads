pragma Ada_2022;

with Adi.Widget_Properties.Enumerated;
pragma Elaborate_All (Adi.Widget_Properties.Enumerated);

with Demo.Elements;

--  Widget properties the stylesheets select on, as in
--  `.alert[severity="critical"]`. `tools/generate.sh` names this package to
--  `css_to_ada.py`, and the generated styles refer to the instantiations
--  and literals below by name, so both have to be declared here.
package Demo.Properties is

   type Severity_Level is (Ok, Warning, Critical);

   package Severity is new Adi.Widget_Properties.Enumerated
     (Name => "severity", Values => Severity_Level);

   package Category is new Adi.Widget_Properties.Enumerated
     (Name => "category", Values => Demo.Elements.Category);

   type Sample_Size is (Small, Medium, Large, Huge);

   package Size is new Adi.Widget_Properties.Enumerated
     (Name => "size", Values => Sample_Size);

   type Switch_State is (Off, On);

   package Bold is new Adi.Widget_Properties.Enumerated
     (Name => "bold", Values => Switch_State);
   package Italic is new Adi.Widget_Properties.Enumerated
     (Name => "italic", Values => Switch_State);
   package Underline is new Adi.Widget_Properties.Enumerated
     (Name => "underline", Values => Switch_State);

   --  The category literals, visible here for the generated styles.
   function Alkali_Metal return Demo.Elements.Category
     renames Demo.Elements.Alkali_Metal;
   function Alkaline_Earth return Demo.Elements.Category
     renames Demo.Elements.Alkaline_Earth;
   function Transition_Metal return Demo.Elements.Category
     renames Demo.Elements.Transition_Metal;
   function Post_Transition return Demo.Elements.Category
     renames Demo.Elements.Post_Transition;
   function Metalloid return Demo.Elements.Category
     renames Demo.Elements.Metalloid;
   function Nonmetal return Demo.Elements.Category
     renames Demo.Elements.Nonmetal;
   function Halogen return Demo.Elements.Category
     renames Demo.Elements.Halogen;
   function Noble_Gas return Demo.Elements.Category
     renames Demo.Elements.Noble_Gas;

end Demo.Properties;
