--  Behaviour behind each page of `ui/`. Every child has the same shape:
--  `Wire` assigns the page's callbacks and must run before `Demo.UI.Build`,
--  which connects them; `Start` runs after it, when the widgets exist.
--  The Layout page has no child: it is XML and CSS only.
package Demo.Pages is
end Demo.Pages;
