with Adi.Log;
with Adi.Widget.Label;

with Demo.UI;

package body Demo.Status is

   procedure Report (Message : String) is
   begin
      Adi.Widget.Label.Set_Text (Demo.UI.Status, Message);
      Adi.Log.Info (Message);
   end Report;

end Demo.Status;
