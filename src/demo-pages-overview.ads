with Adi.Window;

--  Live process figures and a row of Lottie animations.
package Demo.Pages.Overview is

   procedure Wire;

   procedure Start (Window : Adi.Window.Window_Handle);
   --  Loads the animations and refreshes the figures once a second while
   --  the page shows, and the status bar every two seconds otherwise. A missing animation file is reported on
   --  the page and leaves its slot empty.

   procedure Show (Visible : Boolean);
   --  Runs the animations only while the page is on screen and the user
   --  has not paused them. Each animation frame redraws its widget, so a
   --  hidden page would otherwise keep the window drawing.

end Demo.Pages.Overview;
