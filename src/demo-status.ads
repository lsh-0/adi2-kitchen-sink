--  The status line at the foot of the window. Pages report what a control
--  did here, so every interaction leaves a visible trace.
package Demo.Status is

   procedure Report (Message : String);
   --  Shows `Message` in the status bar and logs it at INFO.

end Demo.Status;
