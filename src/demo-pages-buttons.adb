pragma Ada_2022;

with Adi.Widget;               use Adi.Widget;
with Adi.Widget.Box;
with Adi.Widget.Button;
with Adi.Widget.Button.Switch;
with Adi.Widget.Label;

with Buttons_Page_UI;          use Buttons_Page_UI;

with Demo.Properties;
with Demo.Status;
with Demo.Text;
with Demo.UI;

package body Demo.Pages.Buttons is

   package Page renames Demo.UI.Buttons_Page;

   use type Adi.Widget.Box.Box_Handle;
   use type Adi.Widget.Button.Button_Handle;
   use type Adi.Widget.Label.Label_Handle;

   Clicks : Natural := 0;

   function Label_Of (W : Widget_Handle) return String is
     (Adi.Widget.Button.Get_Text (Adi.Widget.Button.Try_As_Button (W)));

   procedure On_Click (W : Widget_Handle) is
      Name : constant String := Label_Of (W);
   begin
      Clicks := Clicks + 1;
      Adi.Widget.Label.Set_Text
        (Page.Click_Count,
         Name & " clicked. " & Text.Image (Clicks) & " clicks so far.");
      Demo.Status.Report ("Button: " & Name);
   end On_Click;

   procedure On_Format (W : Widget_Handle; Active : Boolean) is
      use Demo.Properties;
      Sample : constant Widget_Handle := +Page.Format_Sample;
      State  : constant Switch_State := (if Active then On else Off);
   begin
      if W = +Page.Bold then
         Bold.Set (Sample, State);
      elsif W = +Page.Italic then
         Italic.Set (Sample, State);
      else
         Underline.Set (Sample, State);
      end if;
      Demo.Status.Report
        (Label_Of (W) & (if Active then " on" else " off"));
   end On_Format;

   procedure Show_Radios is
      use Adi.Widget.Button.Switch;
      function Word (On : Boolean) return String is
        (if On then "on" else "off");
   begin
      Adi.Widget.Label.Set_Text
        (Page.Toggle_State,
         "Wi-Fi " & Word (Is_Checked (Page.Wifi))
         & ", Bluetooth " & Word (Is_Checked (Page.Bluetooth))
         & (if Is_Disabled (+Page.Radios) then " (disabled)" else ""));
   end Show_Radios;

   procedure On_Radio (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W, Active);
   begin
      Show_Radios;
   end On_Radio;

   procedure On_Airplane (W : Widget_Handle; Active : Boolean) is
      pragma Unreferenced (W);
   begin
      --  disabling the container disables every descendant, for input and
      --  for the :disabled rules alike
      Set_Disabled (+Page.Radios, Active);
      Show_Radios;
      Demo.Status.Report
        ("Airplane mode " & (if Active then "on" else "off"));
   end On_Airplane;

   procedure On_Size (Value : Sample_Size) is
   begin
      Demo.Properties.Size.Set
        (+Page.Size_Sample,
         Demo.Properties.Sample_Size'Val (Sample_Size'Pos (Value)));
      Demo.Status.Report ("Size: " & Text.Mixed_Case (Value'Image));
   end On_Size;

   procedure Wire is
   begin
      Page.On_Click := On_Click'Access;
      Page.On_Format := On_Format'Access;
      Page.On_Radio := On_Radio'Access;
      Page.On_Airplane := On_Airplane'Access;
      Page.On_Size := On_Size'Access;
   end Wire;

   procedure Start is
   begin
      Size_Options.Set_Selected (Page.Size_Options_Group, Medium);
      Demo.Properties.Size.Set (+Page.Size_Sample, Demo.Properties.Medium);
      Show_Radios;
   end Start;

end Demo.Pages.Buttons;
