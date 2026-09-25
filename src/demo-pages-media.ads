--  Images from the bundle, an icon built from SVG path data, and GIF
--  playback controls.
package Demo.Pages.Media is

   procedure Wire;

   procedure Start;

   procedure Show (Visible : Boolean);
   --  Plays the GIF only while the page is on screen and the user has not
   --  stopped it.

end Demo.Pages.Media;
