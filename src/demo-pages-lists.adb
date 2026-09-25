pragma Ada_2022;

with Adi.Widget;         use Adi.Widget;
with Adi.Widget.Box;
with Adi.Widget.Label;

with Lists_Page_UI;      use Lists_Page_UI;

with Demo.Elements;      use Demo.Elements;
with Demo.Properties;
with Demo.Status;
with Demo.Text;
with Demo.Theme;
with Demo.UI;

package body Demo.Pages.Lists is

   package Page renames Demo.UI.Lists_Page;

   use type Adi.Widget.Box.Box_Handle;
   use type Adi.Widget.Label.Label_Handle;

   --  The rows on screen, in order: row `I` of the list shows `Shown (I)`.
   --  Rebuilt with the rows, so the two cannot disagree.
   Shown      : Selection (1 .. Element'Pos (Element'Last) + 1);
   Shown_Last : Natural := 0;

   function Label
     (Content : String; Classes : String) return Widget_Handle
   is
      L : constant Adi.Widget.Label.Label_Handle :=
        Adi.Widget.Label.Create_Handle (Content);
   begin
      Demo.Theme.Bind (+L, Classes, Tag => "label");
      return +L;
   end Label;

   function Row (E : Element) return Widget_Handle is
      Box   : constant Adi.Widget.Box.Box_Handle := Adi.Widget.Box.Create_Handle;
      Badge : constant Widget_Handle := Label (Symbol (E), "element-badge");
   begin
      Demo.Theme.Bind (+Box, "element-row");
      Demo.Properties.Category.Set (Badge, Table (E).Kind);

      Add_Child (+Box, Label (Text.Image (Number (E)), "element-number"));
      Add_Child (+Box, Badge);
      Add_Child (+Box, Label (Name (E), "element-name"));
      Add_Child (+Box, Label (Table (E).Mass'Image, "element-mass"));
      return +Box;
   end Row;

   procedure Rebuild (Query : String) is
      Found : constant Selection := Filter (Query);
   begin
      --  the list destroys the rows it held, and with them their bindings
      Element_List.Clear_Rows (Page.Elements);
      Shown_Last := Found'Length;
      Shown (1 .. Shown_Last) := Found;
      for E of Found loop
         Element_List.Append_Row (Page.Elements, Row (E));
      end loop;
      Adi.Widget.Label.Set_Text
        (Page.List_Status,
         Text.Image (Shown_Last) & " of"
         & Natural'Image (Element'Pos (Element'Last) + 1) & " elements shown");
   end Rebuild;

   procedure Show_Detail (E : Element) is
   begin
      Adi.Widget.Label.Set_Text (Page.Detail_Symbol, Symbol (E));
      Demo.Properties.Category.Set (+Page.Detail_Symbol, Table (E).Kind);
      Adi.Widget.Label.Set_Text (Page.Detail_Name, Name (E));
      Adi.Widget.Label.Set_Text
        (Page.Detail_Facts,
         "Atomic number " & Text.Image (Number (E)) & ASCII.LF
         & "Mass" & Table (E).Mass'Image & " u" & ASCII.LF
         & Text.Mixed_Case (Table (E).Kind'Image));
   end Show_Detail;

   procedure On_Filter (W : Widget_Handle; Query : String) is
      pragma Unreferenced (W);
   begin
      Rebuild (Query);
   end On_Filter;

   procedure On_Mode (W : Widget_Handle; Index : Natural; Choice : String) is
      pragma Unreferenced (W);
      use Element_List;
      Mode : constant Selection_Mode :=
        (case Index is
            when 2      => Multi_Selection,
            when 3      => Range_Selection,
            when 4      => No_Selection,
            when others => Single_Selection);
   begin
      Set_Selection_Mode (Page.Elements, Mode);
      Demo.Status.Report ("List mode: " & Choice);
   end On_Mode;

   procedure On_Row_Clicked (W : Widget_Handle; Index : Positive; Clicks : Natural) is
      pragma Unreferenced (W, Clicks);
   begin
      if Index <= Shown_Last then
         Show_Detail (Shown (Index));
      end if;
   end On_Row_Clicked;

   procedure On_Row_Activated (W : Widget_Handle; Index : Positive) is
      pragma Unreferenced (W);
   begin
      if Index <= Shown_Last then
         Show_Detail (Shown (Index));
         Demo.Status.Report ("Activated " & Name (Shown (Index)));
      end if;
   end On_Row_Activated;

   procedure On_Selection (W : Widget_Handle) is
      pragma Unreferenced (W);
      Count : constant Natural := Element_List.Get_Selected_Count (Page.Elements);
      Current : constant Natural := Element_List.Get_Current_Row (Page.Elements);
   begin
      if Current in 1 .. Shown_Last then
         Show_Detail (Shown (Current));
      end if;
      Adi.Widget.Label.Set_Text
        (Page.List_Status,
         Text.Image (Shown_Last) & " shown, " & Text.Image (Count) & " selected");
   end On_Selection;

   procedure Wire is
   begin
      Page.On_Filter := On_Filter'Access;
      Page.On_Mode := On_Mode'Access;
      Page.On_Row_Clicked := On_Row_Clicked'Access;
      Page.On_Row_Activated := On_Row_Activated'Access;
      Page.On_Selection := On_Selection'Access;
   end Wire;

   procedure Start is
   begin
      for C in Category loop
         declare
            Chip : constant Widget_Handle :=
              Label (Text.Mixed_Case (C'Image), "legend-chip");
         begin
            Demo.Properties.Category.Set (Chip, C);
            Add_Child (+Page.Legend, Chip);
         end;
      end loop;

      Element_List.Set_Selection_Mode (Page.Elements, Element_List.Single_Selection);
      Rebuild ("");
      Demo.Theme.Track (Page.Mode);
   end Start;

end Demo.Pages.Lists;
