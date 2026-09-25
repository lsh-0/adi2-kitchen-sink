pragma Ada_2022;

with Adi.I18N;
with Adi.OS;
with Adi.Widget;             use Adi.Widget;
with Adi.Widget.Label;
with Adi.Widget.Text_Editor;
with Adi.Widget.Text_Input;

with Inputs_Page_UI;         use Inputs_Page_UI;

with Demo.Meter;
with Demo.Status;
with Demo.Text;
with Demo.Theme;
with Demo.UI;

package body Demo.Pages.Inputs is

   package Page renames Demo.UI.Inputs_Page;

   LF : constant Character := ASCII.LF;

   Sample_Text : constant String :=
     "procedure Hello is" & LF
     & "begin" & LF
     & "   Put_Line (""Hello from the text editor."");" & LF
     & "end Hello;" & LF & LF
     & "Select with the mouse or Shift and the arrows. Ctrl+C, Ctrl+X, Ctrl+V" & LF
     & "and Ctrl+A work, and right-click opens the clipboard menu.";

   procedure Greet (Name : String) is
   begin
      Adi.Widget.Label.Set_Text
        (Page.Greeting,
         (if Name'Length = 0
          then "Type a name. Right-click a field for its clipboard menu."
          else Text.Substitute (Adi.I18N.T ("Hello, %s."), Name)));
   end Greet;

   procedure On_Name (W : Widget_Handle; New_Text : String) is
      pragma Unreferenced (W);
   begin
      Greet (New_Text);
   end On_Name;

   procedure On_Show_Password (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      Adi.Widget.Text_Input.Set_Password_Mode (Page.Password, not Active);
   end On_Show_Password;

   procedure On_Copy (W : Widget_Handle) is
      pragma Unreferenced (W);
      Name : constant String := Adi.Widget.Text_Input.Get_Text (Page.Name);
   begin
      if Adi.OS.Set_Clipboard_Text (Name) then
         Demo.Status.Report ("Copied """ & Name & """ to the clipboard");
      else
         Demo.Status.Report ("The clipboard refused the text");
      end if;
   end On_Copy;

   procedure On_Paste (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      if not Adi.OS.Has_Clipboard_Text then
         Demo.Status.Report ("The clipboard holds no text");
         return;
      end if;
      declare
         Pasted : constant String := Adi.OS.Get_Clipboard_Text;
      begin
         --  Set_Text marks the field changed without emitting Changed,
         --  so the greeting is refreshed here
         Adi.Widget.Text_Input.Set_Text (Page.Name, Pasted);
         Greet (Pasted);
         Demo.Status.Report ("Pasted" & Pasted'Length'Image & " bytes");
      end;
   end On_Paste;

   --  Set_Value on the partner widget does not emit, so each pair can
   --  update the other without echoing back.
   procedure Show_Level (Value : Float) is
   begin
      Demo.Meter.Set_Value
        (Page.Level_Meter, Float'Min (1.0, Float'Max (0.0, Value)));
   end Show_Level;

   procedure On_Level_Slider (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
   begin
      Float_Input.Set_Value (Page.Level_Input, Value);
      Show_Level (Value);
   end On_Level_Slider;

   procedure On_Level_Input (W : Widget_Handle; Value : Float) is
      pragma Unreferenced (W);
   begin
      Float_Slider.Set_Value (Page.Level_Slider, Value);
      Show_Level (Value);
   end On_Level_Input;

   procedure Show_Count (N : Integer) is
      Count : constant Natural := Natural'Max (0, N);
   begin
      Adi.Widget.Label.Set_Text
        (Page.Plural,
         Text.Substitute
           (Adi.I18N.Tn ("%d apple", "%d apples", Count), Text.Image (Count))
         & "  (plural form chosen by the catalogue's rule)");
   end Show_Count;

   procedure On_Count_Slider (W : Widget_Handle; Value : Integer) is
      pragma Unreferenced (W);
   begin
      Int_Input.Set_Value (Page.Count_Input, Value);
      Show_Count (Value);
   end On_Count_Slider;

   procedure On_Count_Input (W : Widget_Handle; Value : Integer) is
      pragma Unreferenced (W);
   begin
      Int_Slider.Set_Value (Page.Count_Slider, Value);
      Show_Count (Value);
   end On_Count_Input;

   procedure On_Fruit (W : Widget_Handle; Index : Natural; Choice : String) is
      pragma Unreferenced (W);
   begin
      Adi.Widget.Label.Set_Text
        (Page.Fruit_Choice,
         "Item" & Index'Image & ": " & Choice);
   end On_Fruit;

   procedure Show_Editor_Stats (Content : String) is
   begin
      Adi.Widget.Label.Set_Text
        (Page.Editor_Stats,
         Text.Image (Text.Count_Lines (Content)) & " lines, "
         & Text.Image (Text.Count_Words (Content)) & " words, "
         & Text.Image (Text.Code_Points (Content)) & " characters");
   end Show_Editor_Stats;

   procedure On_Editor (W : Widget_Handle; Content : String) is
      pragma Unreferenced (W);
   begin
      Show_Editor_Stats (Content);
   end On_Editor;

   procedure On_Read_Only (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      Adi.Widget.Text_Editor.Set_Read_Only (Page.Editor, Active);
      Demo.Status.Report
        ("Editor " & (if Active then "read-only" else "editable"));
   end On_Read_Only;

   procedure Wire is
   begin
      Page.On_Name := On_Name'Access;
      Page.On_Show_Password := On_Show_Password'Access;
      Page.On_Copy := On_Copy'Access;
      Page.On_Paste := On_Paste'Access;
      Page.On_Level_Slider := On_Level_Slider'Access;
      Page.On_Level_Input := On_Level_Input'Access;
      Page.On_Count_Slider := On_Count_Slider'Access;
      Page.On_Count_Input := On_Count_Input'Access;
      Page.On_Fruit := On_Fruit'Access;
      Page.On_Editor := On_Editor'Access;
      Page.On_Read_Only := On_Read_Only'Access;
   end Wire;

   procedure Start is
   begin
      Float_Slider.Set_Step (Page.Level_Slider, 0.05);
      Float_Input.Set_Step (Page.Level_Input, 0.05);
      Show_Level (Float_Slider.Get_Value (Page.Level_Slider));
      Show_Count (Int_Slider.Get_Value (Page.Count_Slider));

      Adi.Widget.Text_Editor.Set_Text (Page.Editor, Sample_Text);
      Show_Editor_Stats (Sample_Text);

      Demo.Theme.Track (Page.Fruit);
      Demo.Theme.Track (Page.Disabled_Combo);
   end Start;

end Demo.Pages.Inputs;
